package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/mitchellh/mapstructure"
)

// DataItem represents the object corresponding to the json that is sent by fluentbit tail plugin
type DataItem struct {
	LogEntry          string `json:"LogEntry"`
	LogEntrySource    string `json:"LogEntrySource"`
	LogEntryTimeStamp string `json:"LogEntryTimeStamp"`
	ID                string `json:"Id"`
	Image             string `json:"Image"`
	Name              string `json:"Name"`
	SourceSystem      string `json:"SourceSystem"`
	Computer          string `json:"Computer"`
}

// ContainerLogBlob represents the object corresponding to the payload that is sent to the ODS end point
type ContainerLogBlob struct {
	DataType  string     `json:"DataType"`
	IPName    string     `json:"IPName"`
	DataItems []DataItem `json:"DataItems"`
}

var (
	certFile = flag.String("cert", "C:\\users\\dilipr\\Downloads\\oms.crt", "OMS Agent Certificate")
	keyFile  = flag.String("key", "C:\\users\\dilipr\\Downloads\\oms.key", "Certificate Private Key")
)

func main() {
	fmt.Println("Starting the application...")
	fmt.Println(time.Now())

	fmt.Println(time.Now())
	var dataItems []DataItem
	for i := 0; i < 10; i++ {
		record := make(map[interface{}]interface{})

		record["LogEntry"] = fmt.Sprintf("dilipr log entry Automated %d", i)
		record["LogEntrySource"] = "stdout"
		record["LogEntryTimeStamp"] = time.Now().UTC().String()
		record["ID"] = "8148673bd69d8368376985753084ca3c4439dfb98c50531419c83b294752bd0a"
		record["Image"] = "nodeconsolelogger"
		record["Name"] = "k8s_diliprlogger_diliprlogger-689f55f96d-7289z_default_3cd372b5-8acf-11e8-b1c8-0a58ac1f32c4_2"
		record["SourceSystem"] = "Containers"
		record["Computer"] = "aks-agentpool-26295126-0"

		var dataItem DataItem

		mapstructure.Decode(record, &dataItem)
		dataItems = append(dataItems, dataItem)
	}

	logEntry := ContainerLogBlob{
		DataType:  "CONTAINER_LOG_BLOB",
		IPName:    "Containers",
		DataItems: dataItems}

	marshalled, err := json.Marshal(logEntry)

	cert, err := tls.LoadX509KeyPair(*certFile, *keyFile)
	if err != nil {
		log.Fatal(err)
	}

	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{cert},
	}

	tlsConfig.BuildNameToCertificate()
	transport := &http.Transport{TLSClientConfig: tlsConfig}

	url := "https://6bb1e963-b08c-43a8-b708-1628305e964a.ods.opinsights.azure.com/OperationalData.svc/PostJsonDataItems"
	client := &http.Client{Transport: transport}
	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(marshalled))

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
	}

	statusCode := resp.Status

	fmt.Println(statusCode)
	fmt.Println(time.Now())
	fmt.Println("Terminating")
}
