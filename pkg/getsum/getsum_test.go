package getsum_test

import (
	"testing"

	"github.com/mkmik/getsum/pkg/getsum"
)

func TestDo(t *testing.T) {
	getsum.Do("foo", "bar")
}
