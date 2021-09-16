package main

import (
	"fmt"
	"io/fs"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {

	path, err := os.Getwd()
	cwdName := filepath.Base(path)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(path)

	files, err := ioutil.ReadDir(path)
	if err != nil {
		fmt.Println(err)
	}

	bytes, err := ioutil.ReadFile(filepath.Join(path, "../index.md"))
	content := string(bytes)
	if err != nil {
		fmt.Println(err)
	}

	emptymds := make([]string, 0)
	missingimages := make([]fs.FileInfo, 0)
	imageexts := []string{".jpg", ".png"}
	for _, f := range files {
		if f.Mode().IsRegular() {
			basename := strings.TrimSuffix(f.Name(), filepath.Ext(f.Name()))
			ext := filepath.Ext(f.Name())
			if ext == ".md" {
				if f.Size() == 0 {
					emptymds = append(emptymds, f.Name())
				}
			}

			_, found := Find(imageexts, ext)
			if found {
				mdfile := basename + ".md"
				_, err := os.Stat(mdfile)
				if os.IsNotExist(err) {
					fmt.Println(mdfile, " does not exist, creating")
					emptyFile, err := os.Create(mdfile)
					if err != nil {
						log.Fatal(err)
					}
					log.Println(emptyFile)
					emptyFile.Close()
				}
				if !strings.Contains(content, f.Name()) {
					missingimages = append(missingimages, f)
				}
			}

		}
	}

	fmt.Println("\n\nALL EMPTY MDS")
	for _, emd := range emptymds {
		fmt.Println(emd)
	}

	fmt.Println("\n\nIMAGES TO BE ADDED TO CONTENT")
	for _, missing := range missingimages {
		idate, _ := time.Parse("2006-01-02", missing.Name()[:10])
		title := missing.Name()[11:]
		title = strings.Replace(title, "-", " ", -1)
		title = strings.Title(title)
		formattedDate := idate.Format("Jan 2, 2006")
		fmt.Printf("{{%% mefigure \"%s/%s\" \"%s, **%s.**\" \"400\" /%%}}\n", cwdName, missing.Name(), formattedDate, title)
	}

}

// Find takes a slice and looks for an element in it. If found it will
// return it's key, otherwise it will return -1 and a bool of false.
func Find(slice []string, val string) (int, bool) {
	for i, item := range slice {
		if item == val {
			return i, true
		}
	}
	return -1, false
}

