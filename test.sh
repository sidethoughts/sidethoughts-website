ls 
ls -l
ls -l --time=birth

echo "README"
git log -1 --format="%ad" --date=iso -- "./README.md"
echo "build.sh format=%ad"
git log -1 --format="%ad" --date=short -- "./build.sh"
echo "build.sh format=fuller"
git log -1 --format="%fuller" --date=short -- "./build.sh"
echo "build.sh format=as"
git log -1 --format="%as" -- "./build.sh"
echo "src/website/home/index.html first commit"
git log --reverse --format="%as" -- "src/website/home/index.html"  | head -1