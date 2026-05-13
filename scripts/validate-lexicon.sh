#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEXICON_FILE="${ROOT_DIR}/lexicon.xml"
EXPECTED_LANG="${EXPECTED_LANG:-en-US}"
EXPECTED_ALPHABET="${EXPECTED_ALPHABET:-ipa}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: missing required command: $1" >&2
    exit 1
  fi
}

xpath_string() {
  xmllint --xpath "string($1)" "$LEXICON_FILE"
}

xpath_number() {
  xmllint --xpath "$1" "$LEXICON_FILE"
}

assert_equals() {
  local actual="$1"
  local expected="$2"
  local message="$3"

  if [[ "$actual" != "$expected" ]]; then
    echo "error: ${message}: expected '${expected}', got '${actual}'" >&2
    exit 1
  fi
}

require_command xmllint

if [[ ! -f "$LEXICON_FILE" ]]; then
  echo "error: lexicon file not found at ${LEXICON_FILE}" >&2
  exit 1
fi

echo "Checking XML well-formedness..."
xmllint --noout "$LEXICON_FILE"

echo "Checking root lexicon metadata..."
assert_equals "$(xpath_string 'local-name(/*)')" "lexicon" "root element must be lexicon"
assert_equals "$(xpath_string 'namespace-uri(/*)')" "http://www.w3.org/2005/01/pronunciation-lexicon" "root namespace must be PLS 1.0"
assert_equals "$(xpath_string '/*/@xml:lang')" "$EXPECTED_LANG" "xml:lang must stay aligned with this repository"
assert_equals "$(xpath_string '/*/@alphabet')" "$EXPECTED_ALPHABET" "alphabet must stay aligned with this repository"

echo "Checking lexeme structure..."
lexeme_count="$(xpath_number 'count(/*[local-name()="lexicon"]/*[local-name()="lexeme"])')"
invalid_lexeme_count="$(xpath_number 'count(/*[local-name()="lexicon"]/*[local-name()="lexeme"][not(*[local-name()="grapheme"]) or not(*[local-name()="alias" or local-name()="phoneme"])])')"
ipa_whitespace_phoneme_count="$(xpath_number 'count(/*[local-name()="lexicon"]/*[local-name()="lexeme"]/*[local-name()="phoneme"][contains(normalize-space(.), " ")])')"

if [[ "$lexeme_count" == "0" ]]; then
  echo "error: lexicon must contain at least one lexeme" >&2
  exit 1
fi

if [[ "$invalid_lexeme_count" != "0" ]]; then
  echo "error: found ${invalid_lexeme_count} lexeme entry or entries without required grapheme plus alias/phoneme content" >&2
  exit 1
fi

if [[ "$EXPECTED_ALPHABET" == "ipa" && "$ipa_whitespace_phoneme_count" != "0" ]]; then
  echo "error: found ${ipa_whitespace_phoneme_count} IPA phoneme entry or entries containing whitespace; Azure custom lexicon IPA phonemes must be contiguous" >&2
  exit 1
fi

echo "Quick validation passed."
echo "Note: this script checks XML structure only. CI still runs Azure's official custom lexicon validator for stricter rule checks."