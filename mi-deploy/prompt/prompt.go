// Package prompt provides functions for prompting the user for various inputs,
// especially with validation of those inputs in mind.
package prompt

import (
	"fmt"
	"strconv"
)

// TODO: allow for regex validation, and ignorecase validation

/********************** GENERAL FUNCTIONS */
// StringPredicate is a function that filters a list of strings
type StringPredicate func(str string) bool

// AnySatisfies checks to see whether any string in a given slice satisfies the
// provided StringPredicate.
func AnySatisfies(pred StringPredicate, slice []string) bool {
	for _, sliceString := range slice {
		if pred(sliceString) {
			return true
		}
	}
	return false
}

// StrIn checks to see if a given string is in a slice of strings.
func StrIn(str string, slice []string) bool {
	pred := func(strx string) bool { return (strx == str) }
	return AnySatisfies(pred, slice)
}

/********************** SPECIFIC FUNCTIONS */
type validator func(string) bool

// Prompt simply presents the user with a string on the terminal line, and
// returns a line of user input.
func Prompt(prompt interface{}) string {
	fmt.Print(prompt)
	var input string
	fmt.Scanln(&input)
	return input
}

// ValidatedPrompt continually prompts the user until valid input is read.
// Input is validated by a validator function.
func ValidatedPrompt(prompt interface{}, valid validator) string {
	input := Prompt(prompt)
	for !valid(input) {
		input = Prompt("Invalid input. Please try again.\n> ")
	}
	return input
}

// validatorConstructor takes a list of valid inputs and makes an input validator
// based on whether or not the input matches those inputs
func validatorConstructor(valid []string) validator {
	return func(input string) bool { return StrIn(input, valid) }
}

// PromptYN prompts the user for a truthy/yesy/falsy/noy string, and collapses
// the range of responses into a simple boolean.
func PromptYN(prompt interface{}) bool {
	yesValues := []string{"yes", "yeah", "sure", "y", "true", "1"}
	noValues := []string{"no", "nah", "nope", "n", "false", "0"}
	validator := validatorConstructor(append(yesValues, noValues...))
	return StrIn(ValidatedPrompt(prompt, validator), yesValues)
}

// a helper function for all promptInts
func promptIntGeneral(prompt interface{}, base, bitLength int) int64 {
	validator := func(input string) bool {
		_, err := strconv.ParseInt(input, base, bitLength)
		return err == nil
	}
	i, _ := strconv.ParseInt(ValidatedPrompt(prompt, validator), base, bitLength)
	return i
}

// PromptInt prompts the user for a valid int.
func PromptInt(prompt interface{}) int {
	return int(promptIntGeneral(prompt, 10, 64))
}

// PromptInt64 prompts the user for a valid int64.
func PromptInt64(prompt interface{}) int64 {
	return promptIntGeneral(prompt, 10, 64)
}

// PromptInt32 prompts the user for a valid int32.
func PromptInt32(prompt interface{}) int32 {
	return int32(promptIntGeneral(prompt, 10, 32))
}

// PromptInt16 prompts the user for a valid int16.
func PromptInt16(prompt interface{}) int16 {
	return int16(promptIntGeneral(prompt, 10, 16))
}

// PromptInt8 prompts the user for a valid int8.
func PromptInt8(prompt interface{}) int8 {
	return int8(promptIntGeneral(prompt, 10, 8))
}

// PromptRange prompts the user for an int within a certain (inclusive) range.
// range=[start, end].
func PromptRange(prompt interface{}, start, end int) int {
	validator := func(input string) bool {
		n, err := strconv.ParseInt(input, 10, 64)
		return (err == nil && int(n) >= start && int(n) <= end)
	}
	input := ValidatedPrompt(prompt, validator)
	n, _ := strconv.ParseInt(input, 10, 64)
	return int(n)
}

// PromptIndex prompts the user for a choice out of a list of items, and
// passes back the index of the item that the user chose.
func PromptIndex(prompt interface{}, lst []string) int {
	toPrompt := fmt.Sprint(prompt)
	for i, item := range lst {
		toPrompt += "\n" + fmt.Sprint(i+1) + ") " + fmt.Sprint(item)
	}
	toPrompt += "\n > "
	return PromptRange(toPrompt, 1, len(lst)) - 1
}

// PromptChoice builds on PromptIndex by passing back the item that the user
// chose, rather than its index.
func PromptChoice(prompt interface{}, lst []string) string {
	return lst[PromptIndex(prompt, lst)]
}
