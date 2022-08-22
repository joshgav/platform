package function

import (
	"context"
	"testing"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/cloudevents/sdk-go/v2/event"
)

// TestHandle ensures that Handle executes without error and returns the
// HTTP 200 status code indicating no errors.
func TestHandle(t *testing.T) {
	e := event.New()
	e.SetID("id")
	e.SetSource("https://joshgav.com/test")
	e.SetSpecVersion(cloudevents.VersionV1)
	e.SetType(cloudevents.ApplicationJSON)
	e.SetData("text/plain", "data")

	err := Handle(context.Background(), e)
	if err != nil {
		t.Fatal(err)
	}
}
