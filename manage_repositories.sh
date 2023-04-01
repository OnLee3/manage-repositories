#!/bin/bash

function get_repositories() {
    gh repo list --limit 100 --json nameWithOwner,isPrivate | jq -r '.[] | "\(.nameWithOwner) \(.isPrivate)"' | sort -k2,2
}

REPOSITORIES=()
while read -r repo is_private; do
    local visibility
    if [[ "$is_private" == "true" ]]; then
        visibility="private"
    else
        visibility="public"
    fi
    REPOSITORIES+=("$repo" "$visibility")
done < <(get_repositories)

declare -A visibility_map=(
    [true]="private"
    [false]="public"
)

function select_repositories() {
    local selected_repositories=()
    local index=1

    echo "Select repositories to manage (Enter the numbers, separated by spaces):"
    for ((i=0; i<${#REPOSITORIES[@]}; i+=2)); do
        repo="${REPOSITORIES[$i]}"
        visibility="${REPOSITORIES[$((i+1))]}"
        printf "[%2d] %-7s %s\n" $index "$visibility" "$repo"
        index=$((index + 1))
    done

    read -ra selected_indexes
    for index in "${selected_indexes[@]}"; do
        repo="${REPOSITORIES[$((2*index-2))]}"
        selected_repositories+=("$repo")
    done

    echo "Selected repositories:"
    printf "%s\n" "${selected_repositories[@]}"
    echo

    REPOSITORIES=("${selected_repositories[@]}")
}

select_repositories

function delete_repositories() {
    for repo in "${REPOSITORIES[@]}"; do
        echo "Deleting repository: $repo"
        gh repo delete "$repo" --yes
        echo "Deleted repository: $repo"
        echo
    done
}

function change_visibility() {
    local visibility="$1"
    for repo in "${REPOSITORIES[@]}"; do
        echo "Changing visibility of repository: $repo"
        gh repo edit "$repo" --visibility "$visibility"
        echo "Updated visibility of repository: $repo"
        echo
    done
}

echo "Choose an action:"
echo "1. Delete repositories"
echo "2. Make repositories public"
echo "3. Make repositories private"
read -p "Enter the number of your choice (1, 2, or 3): " choice

case $choice in
    1)
        delete_repositories
        ;;
    2)
        change_visibility "public"
        ;;
    3)
        change_visibility "private"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Finished managing repositories."
