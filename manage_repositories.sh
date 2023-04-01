function get_repositories() {
    gh repo list --limit 100 --json nameWithOwner | jq -r '.[] | .nameWithOwner'
}

REPOSITORIES=($(get_repositories))

function select_repositories() {
    local selected_repositories=()
    local index=1

    declare -A visibility_map=(
        ["public"]="public "
        ["private"]="private"
    )

    sorted_repositories=($(printf '%s\n' "${REPOSITORIES[@]}" | sort -k 2))
    
    echo "Select repositories to manage (Enter the numbers, separated by spaces):"
    for repo in "${sorted_repositories[@]}"; do
        is_private="$(gh repo view --json isPrivate "$repo" | jq -r '.isPrivate')"
        if [[ $is_private == "true" ]]; then
            visibility_string="private"
        else
            visibility_string="public"
        fi
        echo "[$index] $visibility_string $repo"
        index=$((index + 1))
    done

    read -ra selected_indexes
    for index in "${selected_indexes[@]}"; do
        selected_repositories+=("${sorted_repositories[$((index - 1))]}")
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
