package Cx

CxPolicy [ result ] {
  document := input.document
  resource = document[i].Resources[name]
  resource.Type == "AWS::AmazonMQ::Broker"
  properties := resource.Properties
  exists_eo := object.get(properties, "EncryptionOptions", "undefined") != "undefined"
  not exists_eo
  
      result := {
                "documentId": 		input.document[i].id,
                "searchKey":        sprintf("Resources.%s.Properties.EncryptionOptions", [name]),
                "issueType":		   "MissingAttribute",
                "keyExpectedValue": sprintf("Resources.%s.Properties.EncryptionOptions is defined", [name]),
                "keyActualValue": 	sprintf("Resources.%s.Properties.EncryptionOptions is not defined", [name])
              }
}