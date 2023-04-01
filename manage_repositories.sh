#!/bin/bash

get_repositories() {
    gh repo list --limit 100 --json nameWithOwner,isPrivate \
        | jq -r '.[] | "\(.nameWithOwner) \(.isPrivate)"' \
        | sort -k2,2
}

select_repositories() {
    local selected_repositories=()
    local index=1

    echo "Select repositories to manage (Enter the numbers, separated by spaces):"
    while read -r repo is_private; do
        local visibility="public"
        if [[ "$is_private" == "true" ]]; then
            visibility="private"
        fi
        printf "[%2d] %-7s %s\n" $index "$visibility" "$repo"
        REPOSITORIES+=("$repo")
        index=$((index + 1))
    done < <(get_repositories)

    read -ra selected_indexes
    for index in "${selected_indexes[@]}"; do
        selected_repositories+=("${REPOSITORIES[$index-1]}")
    done

    echo "Selected repositories:"
    printf "%s\n" "${selected_repositories[@]}"
    echo

    REPOSITORIES=("${selected_repositories[@]}")
}

delete_repositories() {
    for repo in "${REPOSITORIES[@]}"; do
        echo "Deleting repository: $repo"
        gh repo delete "$repo" --yes
        echo "Deleted repository: $repo"
        echo
    done
}

change_visibility() {
    local visibility="$1"
    for repo in "${REPOSITORIES[@]}"; do
        echo "Changing visibility of repository: $repo"
        gh repo edit "$repo" --visibility "$visibility"
        echo "Updated visibility of repository: $repo"
        echo
    done
}

echo "Choose an action:"
PS3="Enter the number of your choice (1, 2, or 3): "
options=("Delete repositories" "Make repositories public" "Make repositories private" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Delete repositories")
            select_repositories
            delete_repositories
            break
            ;;
        "Make repositories public")
            select_repositories
            change_visibility "public"
            break
            ;;
        "Make repositories private")
            select_repositories
            change_visibility "private"
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "Invalid option. Try again.";;
    esac
done

echo "Finished managing repositories."
