package schema

#Ring:          "rescue" | "bootstrap" | "validate" | "workflow"
#Severity:      "fatal" | "degraded" | "warning"
#ArtifactClass: "config" | "state" | "cache" | "runtime"
#Activation:    "copy" | "atomic-copy" | "none"

#Artifact: {
	id:           string
	class:        #ArtifactClass
	source?:      string
	target:       string
	mode?:        =~"^[0-7]{3,4}$"
	activation:   #Activation | *"none"
	userEditable: bool | *false
	generated:    bool | *false
	ring:         #Ring
}

#Check: {
	id:       string
	command:  string
	severity: #Severity
	provides?: [...string]
}

#Domain: {
	id:   string
	ring: #Ring
	owns: {
		config?: [...#Artifact]
		state?: [...#Artifact]
		cache?: [...#Artifact]
		runtime?: [...#Artifact]
	}
	provides: [...string]
	checks: [...#Check]
}
