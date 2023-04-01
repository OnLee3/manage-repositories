# Repository Manager

This is a command-line tool that allows you to manage your GitHub repositories in bulk. You can select a group of repositories and either delete them or change their visibility to public or private.

## Prerequisites

-   [GitHub CLI](https://cli.github.com/) installed and authenticated with your GitHub account.
-   Execute permission for the `manage-repositories.sh` script. Run the command `chmod +x manage-repositories.sh` in the project directory to add the permission.

## How to use

1.  Clone this repository and navigate to the project directory in your terminal.
2.  Run the command `./manage-repositories.sh`.
3.  The repositories will be listed in ascending order of visibility, with private repositories first.
4.  Select the repositories you want to manage by entering their numbers.
5.  Choose the action you want to perform: delete repositories, make repositories public, or make repositories private.
6.  Follow the prompts to complete the selected action.

## License

This project is licensed under the [MIT License](https://chat.openai.com/LICENSE).

## Acknowledgements

This tool was created using the [GitHub CLI](https://cli.github.com/) and [jq](https://stedolan.github.io/jq/).