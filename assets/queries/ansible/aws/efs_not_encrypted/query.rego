package Cx

CxPolicy [ result ] {
  document := input.document[i]
  tasks := getTasks(document)
  task := tasks[t]
  fs := task["community.aws.efs"]
  fsName := task.name

  object.get(fs, "encrypt", "undefined") == "undefined"


    result := {
                "documentId":       input.document[i].id,
                "searchKey":        sprintf("name={{%s}}.{{community.aws.efs}}", [fsName]),
                "issueType":        "MissingAttribute",
                "keyExpectedValue": "community.aws.efs.encrypt should be set to true",
                "keyActualValue":   "community.aws.efs.encrypt is undefined"
              }
}

CxPolicy [ result ] {
  document := input.document[i]
  tasks := getTasks(document)
  task := tasks[t]
  fs := task["community.aws.efs"]
  fsName := task.name

  not isAnsibleTrue(fs.encrypt)

  result := {
              "documentId":       input.document[i].id,
              "searchKey":        sprintf("name={{%s}}.{{community.aws.efs}}.encrypt", [fsName]),
              "issueType":        "WrongValue",
              "keyExpectedValue": "community.aws.efs.encrypt should be set to true",
              "keyActualValue":   "community.aws.efs.encrypt is set to false"
            }
}


getTasks(document) = result {
    result := [body | playbook := document.playbooks[0]; body := playbook.tasks]
    count(result) != 0
} else = result {
    result := [body | playbook := document.playbooks[_]; body := playbook ]
    count(result) != 0
}

isAnsibleTrue(answer) {
 	lower(answer) == "yes"
} else {
	answer == true
}