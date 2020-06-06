#!/bin/bash

echo "Collecting stats for badges..."

commits=$(git rev-list --all --count)

latest_release_tag=$(git describe --tags "$(git rev-list --tags --max-count=1)")
latest_release_timestamp=$(git log -1 --format=%ct "$latest_release_tag")
latest_release_date=$(date -d @"$latest_release_timestamp" +"%h %Y")

authors=$(git shortlog -sne)
authorsCount=$(echo "$authors" | wc -l)

first_commit_hash=$(git rev-list --max-parents=0 HEAD)
first_commit_timestamp=$(git show -s --format=%ct "$first_commit_hash")

commits_since_last_release_hashes=$(git rev-list "$latest_release_tag"..HEAD)
commits_since_last_release=$(echo "$commits_since_last_release_hashes" | wc -l)

repository_creation_day_timestamp=$(git show -s --format=%ct "$first_commit_hash")
repository_creation_day=$(date -d @"$repository_creation_day_timestamp" +%d.%m.%Y)

difference_in_seconds=$(($(date +"%s") - first_commit_timestamp))
difference_in_minutes=$((difference_in_seconds / 60))
difference_in_hours=$((difference_in_minutes / 60))
difference_in_days=$((difference_in_hours / 24))
difference_in_months=$((difference_in_days / 30))
difference_in_years=$((difference_in_days / 365))

time_repository_exists="$difference_in_months months $((difference_in_days - (difference_in_months * 30))) days"

if [ "$difference_in_minutes" -eq 0 ]; then
  difference_in_minutes=1
fi
if [ "$difference_in_hours" -eq 0 ]; then
  difference_in_hours=1
fi
if [ "$difference_in_months" -eq 0 ]; then
  difference_in_months=1
fi
if [ "$difference_in_years" -eq 0 ]; then
  difference_in_years=1
fi
commits_per_second=$((commits / difference_in_seconds))
commits_per_minute=$((commits / difference_in_minutes))
commits_per_hour=$((commits / difference_in_hours))
commits_per_month=$((commits / difference_in_months))
commits_per_year=$((commits / difference_in_years))

last_commit_hash=$(git rev-list HEAD^..HEAD)
last_commit_timestamp=$(git show -s --format=%ct "$last_commit_hash")
last_commit_date=$(date -d @"$last_commit_timestamp" +"%h %Y")

git gc -q
git_repository_size=$(du -sh)
git_repository_size=$(echo "$git_repository_size" | xargs)
git_file_size=$(du -sh .git/)
git_file_size=$(echo "$git_file_size" | xargs)

echo "{\"commits\":\"$commits\", \"release_tag\":\"$latest_release_tag\", \"all_contributors\":\"$authorsCount\",
 \"commits_per_second\":\"$commits_per_second\", \"commits_per_minute\":\"$commits_per_minute\", \"commits_per_hour\":\"$commits_per_hour\", \"commits_per_month\":\"$commits_per_month\", \"commits_per_year\":\"$commits_per_year\",
 \"commit_activity\":\"$commits_per_month/month\",
 \"time_repository_exists\":\"$time_repository_exists\", \"repository_creation_day\":\"$repository_creation_day\",
 \"commits_since_last_release\":\"$commits_since_last_release\",
 \"last_commit_date\":\"$last_commit_date\", \"last_release_date\":\"$latest_release_date\",
 \"repository_size\":\"$git_repository_size\", \"repository_file_size\":\"$git_file_size\",
 }" >badges.json
