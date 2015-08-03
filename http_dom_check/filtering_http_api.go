package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/lib/pq"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"time"
)

/*config exampl file contnet:
{
    "HttpPort": "8080",
    "DbUser": "eliezer",
    "DbPass": "123456",
    "DbHost": "127.0.0.1",
    "DbPort": "",
    "DbName": "filtering",
    "Debug": "Yes"
}
*/

type Configuration struct {
	HttpPort string
	DbUser   string
	DbPass   string
	DbHost   string
	DbPort   string
	DbName   string
	Debug    string
}

var configuration Configuration

var db *sql.DB
var err error
var validDomain = regexp.MustCompile(`^[a-z0-9\.\-\_]+$`)

func domainLookup(w http.ResponseWriter, r *http.Request) {
	m, _ := url.ParseQuery(r.URL.RawQuery)
	if validDomain.MatchString(m["domain"][0]) {
		//cacheSince := time.Now().Format(http.TimeFormat)
		cacheUntil := time.Now().AddDate(600, 0, 0).Format(http.TimeFormat)
		if configuration.Debug == "Yes" {
			fmt.Println("The is a valid domain => \"" + m["domain"][0] + "\"")
		}
		w.Header().Set("Cache-Control", "public, max-age=600")
		w.Header().Set("Expires", cacheUntil)
		w.Header().Set("Content-Type", "text/plain")
		ans, err := sexDomain(m["domain"][0])
		if err == nil {

		}
		if ans {
			io.WriteString(w, "ERR rate=100")
			return
		}

		if net.ParseIP(m["domain"][0]) != nil {

			io.WriteString(w, "OK comment=ip_stop_condition")
			return
		}

		domArr := strings.Split(m["domain"][0], ".")
		for i := (len(domArr) - 1); i > 0; i-- {
			ans, err := sexDomain(strings.Join(domArr[i:len(domArr)], "."))
			if err == nil {
			}
			if ans {
				io.WriteString(w, "ERR rate=100")
				return
			}

		}
	}

	io.WriteString(w, "OK")
	return
}

func sexDomain(dom string) (sexAnswer bool, err error) {
	var stmt *sql.Stmt

	stmt, err = db.Prepare(`SELECT dom FROM domains WHERE dom = $1 AND sex = true LIMIT 1`)

	if err != nil {
		fmt.Printf("db.Prepare error: %v\n", err)
		return false, err
	}

	var rows *sql.Rows

	rows, err = stmt.Query(dom)
	if err != nil {
		fmt.Printf("stmt.Query error: %v\n", err)
		return false, err
	}

	defer stmt.Close()
	if rows.Next() {
		var domain string

		err = rows.Scan(&domain)
		if err != nil {
			fmt.Printf("rows.Scan error: %v\n", err)
			return false, err
		}
    if configuration.Debug == "Yes" {
		  fmt.Println("domain => \"" + domain + "\"")
    }
		return true, err
	}

	return false, nil
}

func urlLookup(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "ERR reason=not_implemented_YET")
}

func main() {

	file, _ := os.Open("http_conf.json")
	decoder := json.NewDecoder(file)
	err := decoder.Decode(&configuration)
	if err != nil {
		fmt.Println("error:", err)
	}
	if configuration.Debug == "Yes" {
		fmt.Println("Config File Variables:")
		fmt.Println("http port: =>" + configuration.HttpPort)
		fmt.Println("Database User: =>" + configuration.DbUser)
		fmt.Println("Database Password: =>" + configuration.DbPass)
		fmt.Println("Database Host: =>" + configuration.DbHost)
		fmt.Println("Database Port(ignored): =>" + configuration.DbPort)
		fmt.Println("Database Name: =>" + configuration.DbName)
		fmt.Println("Debug Mode: =>" + configuration.Debug)

	}
  if configuration.Debug == "Yes" {
	fmt.Printf("Testing DB connectivity..\n")
  }
	db, err = sql.Open("postgres", "user="+configuration.DbUser+" dbname="+configuration.DbName+" host="+configuration.DbHost+" password="+configuration.DbPass)

	if err != nil {
		fmt.Printf("sql.Open error: %v\n", err)
		return
	}

	defer db.Close()
  if configuration.Debug == "Yes" {
	  fmt.Printf("Database probably connected!\n")
  }
	http.HandleFunc("/d/", domainLookup)
	http.HandleFunc("/u/", urlLookup)
	http.ListenAndServe(":"+ configuration.HttpPort, nil)
}
