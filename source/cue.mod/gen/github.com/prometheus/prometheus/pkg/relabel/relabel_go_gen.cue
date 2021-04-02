// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/prometheus/prometheus/pkg/relabel

package relabel

// Action is the action to be performed on relabeling.
#Action: _ // #enumAction

#enumAction:
	#Replace |
	#Keep |
	#Drop |
	#HashMod |
	#LabelMap |
	#LabelDrop |
	#LabelKeep

// Replace performs a regex replacement.
#Replace: #Action & "replace"

// Keep drops targets for which the input does not match the regex.
#Keep: #Action & "keep"

// Drop drops targets for which the input does match the regex.
#Drop: #Action & "drop"

// HashMod sets a label to the modulus of a hash of labels.
#HashMod: #Action & "hashmod"

// LabelMap copies labels to other labelnames based on a regex.
#LabelMap: #Action & "labelmap"

// LabelDrop drops any label matching the regex.
#LabelDrop: #Action & "labeldrop"

// LabelKeep drops any label not matching the regex.
#LabelKeep: #Action & "labelkeep"

// Config is the configuration for relabeling of target label sets.
#Config: _

// Regexp encapsulates a regexp.Regexp and makes it YAML marshalable.
#Regexp: _
