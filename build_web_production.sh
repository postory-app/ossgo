echo "Web build start \x1b[0;34m(Prod)\x1b[0m"
fvm flutter clean
fvm flutter build web --release --web-renderer canvaskit --output=build/postory
echo "Web build completed \x1b[0;34m(Prod)\x1b[0m"