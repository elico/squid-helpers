package main

import (
	"fmt"
	"os"
	"log"
	"log/syslog"
	"bufio"
	"strings"
	"net/http"
	"io/ioutil"
	"strconv"
	"encoding/json"
)

/*
config exampl file contnet:
{
    "ApiHttpUrl": "http://filterdb/d/?domain=",
    "Debug": "No"
} 
Another example when using a riak bucket:
 http_api_conf.json.riak 
{
    "ApiHttpUrl": "http://filterdb:8098/buckets/blocked/keys/",
    "Debug": "No"
}
*/

type Configuration struct {
	ApiHttpUrl string
	DefaultAnswer string
	Debug	string
}

var configuration Configuration


func checkdom(domain string) string{
	if configuration.Debug == "Yes" {
		fmt.Fprintf(os.Stderr, "ERRlog: reporting query => \"" + domain + "\"\n")
	}
	resp, err := http.Get(configuration.ApiHttpUrl + domain)
	if err != nil {
            return "DUNO"
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
        if body != nil {
	    return string(body)
        }
        return "DUNO"
}

func process_request(line string) {
		lparts := strings.Split( strings.TrimRight(line, "\n"), " ")
		if len(lparts[0]) > 0 {
			if configuration.Debug == "Yes" {
				fmt.Fprintf(os.Stderr, "ERRlog: Request nubmer => " + lparts[0] + "\n")
			}
		}
		/* v := "4"
		if _, err := strconv.Atoi(v); err == nil {
			fmt.Fprintf(os.Stderr, "ERR:" + v + "looks like a number")
		}
        	log.Println(line)
	        */
		answer := checkdom(lparts[1])
		if configuration.Debug == "Yes" {
			fmt.Fprintf(os.Stderr, "ERRlog: reporting answer size => " + strconv.Itoa(len(answer)) + "\n")
			fmt.Fprintf(os.Stderr, "ERRlog: reporting answer => " + answer + "\n")

		}

		if strings.HasPrefix(answer, "ERR") {
			if configuration.Debug == "Yes" {
				fmt.Fprintf(os.Stderr, "ERRlog: reporting answer startsWith => \"OK\"\n")
			}
			fmt.Println(lparts[0] + " ERR rate=100")
		}
		if strings.HasPrefix(answer, "not found") || strings.HasPrefix(answer, "OK") {
			if configuration.Debug == "Yes" {
				fmt.Fprintf(os.Stderr, "ERRlog: reporting answer startsWith => \"OK\" or \"not found\"\n")
			}
			fmt.Println(lparts[0] + " OK")
		}
		if strings.HasPrefix(answer, "DUNO") {
			if configuration.Debug == "Yes" {
				fmt.Fprintf(os.Stderr, "ERRlog: reporting answer startsWith => \"DUNO\"\n")
			}
			if len(configuration.DefaultAnswer) > 0  {
				fmt.Println(lparts[0] + " " + configuration.DefaultAnswer + " rate=100")
			} else {
				fmt.Println(lparts[0] + " OK state=DUNO")
			}
		}

}

//var err error
func main() {
	reader := bufio.NewReader(os.Stdin)

	l2, err := syslog.New(syslog.LOG_ERR, "[filter_helper]")
	defer l2.Close()
	if err != nil {
	    log.Fatal("error writing syslog!")
	}

	l2.Notice("hello go, running under squid :D")

	file, _ := os.Open("http_api_conf.json")
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&configuration)

	if err != nil {
		fmt.Println("error:", err)
	}
	if configuration.Debug == "Yes" {
		l2.Notice("Config File Variables:")
		l2.Notice("api http url: => " + configuration.ApiHttpUrl)
	}


    for {
        line, err := reader.ReadString('\n')

        if err != nil {
            // You may check here if err == io.EOF
            break
        }

		go process_request(line)

    }
}

