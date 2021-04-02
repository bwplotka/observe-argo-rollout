// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/prometheus/common/config

package config

_#closeIdler: _

// BasicAuth contains basic HTTP authentication credentials.
#BasicAuth: _

// Authorization contains HTTP authorization credentials.
#Authorization: {
	type?:             string  @go(Type)
	credentials?:      #Secret @go(Credentials)
	credentials_file?: string  @go(CredentialsFile)
}

// URL is a custom URL type that allows validation at configuration load time.
#URL: _

// HTTPClientConfig configures an HTTP client.
#HTTPClientConfig: _

// TLSConfig configures the options for TLS connections.
#TLSConfig: _
