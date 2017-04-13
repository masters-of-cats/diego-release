$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd diego-release/

$env:GOPATH=($pwd).path
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;" + $env:PATH
# Write-Host "Gopath is " + $env:GOPATH
# Write-Host "PATH is " + $env:PATH

go install github.com/apcera/gnatsd
# go install github.com/coreos/etcd

Write-Host "Installing Ginkgo"
go install github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
} else {
  Write-Host "Ginkgo successfully installed"
}

Write-Host "Running store-dependent test suites against a MySQL database..."
$env:DB_UNITS="./bbs/db/sqldb"
$env:SQL_FLAVOR="mysql"

cd src/code.cloudfoundry.org/

ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race rep/cmd/rep
# ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race rep/cmd/rep rep/generator/internal route-emitter/cmd/route-emitter bbs/db/sqldb

# $scripts_path/run-unit-tests-no-backing-store

if ($LastExitCode -ne 0) {
    Write-Host "Diego unit tests failed"
    exit 1
} else {
  Write-Host "Diego unit tests passed"
  exit 0
}

