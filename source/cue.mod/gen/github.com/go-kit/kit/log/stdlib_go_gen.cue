// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/go-kit/kit/log

package log

// StdlibWriter implements io.Writer by invoking the stdlib log.Print. It's
// designed to be passed to a Go kit logger as the writer, for cases where
// it's necessary to redirect all Go kit log output to the stdlib logger.
//
// If you have any choice in the matter, you shouldn't use this. Prefer to
// redirect the stdlib log to the Go kit logger via NewStdlibAdapter.
#StdlibWriter: {
}

// StdlibAdapter wraps a Logger and allows it to be passed to the stdlib
// logger's SetOutput. It will extract date/timestamps, filenames, and
// messages, and place them under relevant keys.
#StdlibAdapter: {
	Logger: #Logger
}

_#logRegexpDate: "(?P<date>[0-9]{4}/[0-9]{2}/[0-9]{2})?[ ]?"             // `(?P<date>[0-9]{4}/[0-9]{2}/[0-9]{2})?[ ]?`
_#logRegexpTime: "(?P<time>[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?)?[ ]?" // `(?P<time>[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?)?[ ]?`
_#logRegexpFile: "(?P<file>.+?:[0-9]+)?"                                 // `(?P<file>.+?:[0-9]+)?`
_#logRegexpMsg:  "(: )?(?P<msg>.*)"                                      // `(: )?(?P<msg>.*)`
