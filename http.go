package main

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

func main() {
	fmt.Println("Starting the application...")

	type ContainerLogBlob struct {
		DataType  string `json:"DataType"`
		IPName    string `json:"IPName"`
		DataItems []struct {
			LogEntry          string `json:"LogEntry"`
			LogEntrySource    string `json:"LogEntrySource"`
			LogEntryTimeStamp string `json:"LogEntryTimeStamp"`
			ID                string `json:"Id"`
			Image             string `json:"Image"`
			Name              string `json:"Name"`
			SourceSystem      string `json:"SourceSystem"`
			Computer          string `json:"Computer"`
		} `json:"DataItems"`
	}

	dataItems := []struct {
		LogEntry          string `json:"LogEntry"`
		LogEntrySource    string `json:"LogEntrySource"`
		LogEntryTimeStamp string `json:"LogEntryTimeStamp"`
		ID                string `json:"Id"`
		Image             string `json:"Image"`
		Name              string `json:"Name"`
		SourceSystem      string `json:"SourceSystem"`
		Computer          string `json:"Computer"`
	}{
		{
			LogEntry:          "dilipr log entry",
			LogEntrySource:    "stdout",
			LogEntryTimeStamp: "2018-07-20T20:24:30.322698884Z",
			ID:                "8148673bd69d8368376985753084ca3c4439dfb98c50531419c83b294752bd0a",
			Image:             "nodeconsolelogger",
			Name:              "k8s_diliprlogger_diliprlogger-689f55f96d-7289z_default_3cd372b5-8acf-11e8-b1c8-0a58ac1f32c4_2",
			SourceSystem:      "Containers",
			Computer:          "aks-agentpool-26295126-0",
		},
	}

	logEntry := ContainerLogBlob{
		DataType:  "CONTAINER_LOG_BLOB",
		IPName:    "Containers",
		DataItems: dataItems}

	marshalled, err := json.Marshal(logEntry)
	workspaceID := "6bb1e963-b08c-43a8-b708-1628305e964a"
	key := "YonW5ePdSytdCh+zAgG3pMiCaehbXcaf/AaNdRZH2OaN362f/feXcCVwYWgRIGvZ5v9zmV0TmGXDE1so7mNrUg=="
	timeStamp := time.Now().UTC().Format(time.RFC1123)
	authorization := buildSignature(workspaceID, key, len(marshalled), timeStamp)
	timeStampField := "DateValue"

	url := "https://6bb1e963-b08c-43a8-b708-1628305e964a.ods.opinsights.azure.com/OperationalData.svc/PostJsonDataItems"
	client := &http.Client{}
	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(marshalled))

	req.Header.Add("x-ms-date", timeStamp)
	// req.Header.Add("x-ms-UUID", "0036E068-9C33-6142-84AE-059C157D0991")
	// req.Header.Add("Content-Type", "application/json")
	// req.Header.Add("X-Request-ID", "dc9076e9-2fda-4019-bd2c-900a8284b9c4")
	req.Header.Add("Authorization", authorization)
	req.Header.Add("time-generated-field", timeStampField)

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
	}

	f, _ := ioutil.ReadAll(resp.Body)

	fmt.Println(string(f))
	fmt.Println("Terminating")
}

func buildSignature(workspaceID string, key string, length int, timeStamp string) string {
	resource := "/OperationalData.svc/PostJsonDataItems"

	xHeaders := fmt.Sprintf("x-ms-date:%s", timeStamp)
	contentType := "application/json"
	method := "POST"
	hashString := fmt.Sprintf("%s\n%d\n%s\n%s\n%s", method, length, contentType, xHeaders, resource)
	hashBytes := []byte(hashString)

	keyBytes, _ := base64.StdEncoding.DecodeString(key)
	sha256 := hmac.New(sha256.New, keyBytes)

	sha256.Write(hashBytes)

	calculatedHash := sha256.Sum(nil)

	encodedHash := base64.StdEncoding.EncodeToString(calculatedHash)

	authorization := fmt.Sprintf("SharedKey %s:%s", workspaceID, encodedHash)
	return authorization
}

// Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
// {

//     $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

//     $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)

//     $sha256 = New-Object System.Security.Cryptography.HMACSHA256
//     $sha256.Key = $keyBytes
//     $calculatedHash = $sha256.ComputeHash($bytesToHash)
//     $encodedHash = [Convert]::ToBase64String($calculatedHash)
//     $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
//     return $authorization
// }
