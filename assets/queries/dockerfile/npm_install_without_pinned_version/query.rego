package Cx

CxPolicy [ result ] {
  runCmd := input.document[i].command[name][_]
  isRunCmd(runCmd) 
  
  value := runCmd.Value
  count(value) == 1 #command is in a single string

  cmd := value[0]

  searchIndex := indexof(cmd,"npm install")

  searchIndex != -1

  npmInstallCmd := trimCmdEnd(substring(cmd,searchIndex+12,count(cmd)-searchIndex-12))

  not isValidInstall(npmInstallCmd)

	result := {
                "documentId": 		input.document[i].id,
                "searchKey": 	    sprintf("FROM={{%s}}.{{%s}}", [name,runCmd.Original]),
                "issueType":		"IncorrectValue", 
                "keyExpectedValue": sprintf("'%s' uses npm install with a pinned version", [runCmd.Original]),
                "keyActualValue": 	sprintf("'%s' does not uses npm install with a pinned version", [runCmd.Original])
              }
}

CxPolicy [ result ] {
  runCmd := input.document[i].command[name][_]
  isRunCmd(runCmd) 
  
  value := runCmd.Value
  count(value) > 1 #command is in several tokens
  
  npmInstallIndex := getNPMInstallCmdIdx(value)
  npmInstallIndex != -1
  npmInstallCmd := value[npmInstallIndex]

  not isValidInstall(npmInstallCmd)

	result := {
                "documentId": 		input.document[i].id,
                "searchKey": 	    sprintf("FROM={{%s}}.{{%s}}", [name,runCmd.Original]),
                "issueType":		"IncorrectValue", 
                "keyExpectedValue": sprintf("'%s' uses npm install with a pinned version", [runCmd.Original]),
                "keyActualValue": 	sprintf("'%s' does not uses npm install with a pinned version", [runCmd.Original])
              }
}

isRunCmd(com) = true{
  com.Cmd == "run"
} else = false

trimCmdEnd(cmd) = trimmed {
  termOps := ["&&","||","|","&",";"]

  splitStr := split(cmd," ")
  some i, j
      splitStr[i] == termOps[j] 
      indexTerm := indexof(cmd,termOps[j])
      trimmed := substring(cmd,0,count(cmd) - indexTerm)
} else = cmd

isValidInstall(install) {
  install == ""
} else {
  startswith(install,"git") # npm install from git repository
} else {
  hasScope := regex.match(install,"@.+\/")
  hasScope

  scopeEnd := indexof(install,"/")
  packageID := substring(install,scopeEnd+1,count(install) - scopeEnd)
  atIndex := indexof(packageID,"@")
  atIndex != -1 #package must refer the version or tag
} else {
  hasScope := regex.match(install,"@.+\/")
  not hasScope
  atIndex := indexof(install,"@")
  atIndex != -1 #package must refer the version or tag
} else = false

getNPMInstallCmdIdx(value) = idx {
  some i
    value[i] == "npm"
    value[i+1] == "install"
    idx := i+2
} else = -1