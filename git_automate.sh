#!/bin/bash

# Color variables
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

display_commits() {
    echo -e "${GREEN}-------- List of Commits --------${RESET}"

    COMMIT_DATA=$(git log --oneline --color=always)
    # Format as a table
    TABLE=$(echo "$COMMIT_DATA" | column -t -s "|")

    echo -e "$TABLE"
}

create_commit() {
    echo -e "${GREEN}-------- Create Simple Commit --------${RESET}"

    read -rp "Enter commit message: " MESSAGE

    echo -e "${YELLOW}Commit message to be executed:${RESET}"
    echo -e "${YELLOW}$MESSAGE${RESET}"

    read -rp "Are you sure you want to create this commit? (y/n): " CHOICE
    if [[ $CHOICE == "y" ]]; then
        git commit -m "$MESSAGE"
        echo -e "${GREEN}Commit created successfully!${RESET}"
    else
        echo -e "${RED}Commit creation canceled.${RESET}"
    fi
}

edit_commits() {
    echo -e "${GREEN}-------- Edit Commits --------${RESET}"
    display_commits

    read -rp "Enter the commit number to edit: " COMMIT_NUMBER

    COMMIT_MESSAGE=$($COMMIT_DATA -"$COMMIT_NUMBER" | tail -n 1)

    echo -e "${GREEN}Commit to be edited:${RESET}"
    echo -e "${GREEN}$COMMIT_MESSAGE${RESET}"

    read -rp "Are you sure you want to edit this commit? (y/n): " CHOICE
    if [[ $CHOICE == "y" ]]; then
        git commit --amend "$COMMIT_NUMBER"
        echo -e "${GREEN}Commit edited successfully!${RESET}"
    else
        echo -e "${RED}Commit edit canceled.${RESET}"
    fi
}

execute_commit() {
    echo -e "${GREEN}-------- Execute Commits --------${RESET}"
    display_commits

    read -rp "Enter the commit number to execute: " COMMIT_NUMBER

    COMMIT_MESSAGE=$(git log --oneline -"$COMMIT_NUMBER" | tail -n 1)

    echo -e "${GREEN}Commit to be executed:${RESET}"
    echo -e "${GREEN}$COMMIT_MESSAGE${RESET}"

    read -rp "Are you sure you want to execute this commit? (y/n): " CHOICE
    if [[ $CHOICE == "y" ]]; then
        echo -e "${GREEN}Commit executed successfully!${RESET}"
        exit 0
    else
        echo -e "${RED}Commit execution canceled.${RESET}"
    fi
}

delete_commits() {
    echo -e "${GREEN}-------- Delete Commits --------${RESET}"
    display_commits

    read -rp "Enter the commit number to delete: " COMMIT_NUMBER

    echo -e "${GREEN}Commits to be deleted:${RESET}"
    git log --oneline -"$COMMIT_NUMBER"

    read -rp "Are you sure you want to delete these commits? (y/n): " CHOICE
    if [[ $CHOICE == "y" ]]; then
        git rebase -i HEAD~"$COMMIT_NUMBER"
        echo -e "${GREEN}Commits deleted successfully!${RESET}"
    else
        echo -e "${RED}Commit deletion canceled.${RESET}"
    fi
}

semantic_commit_messages() {
    echo -e "${GREEN}-------- Multiple Commit Messages --------${RESET}"

    echo -e "Choose the type of commit:
1. ${GREEN}build${RESET}: (include changes to build scripts, configurations, or tools used in the build process)
2. ${GREEN}chore:${RESET} (include things like updating packages, refactoring code for readability, or modifying development environment settings)
3. ${GREEN}ci${RESET}: (include modifications to the CI pipeline, build servers, or automated testing configurations)
4. ${GREEN}feat${RESET}: (involve adding new code, APIs, or significant enhancements to existing features)
5. ${GREEN}fix:${RESET} (include patches, hotfixes, or any changes that address a problem or bug)
6. ${GREEN}docs:${RESET} (include changes to README files, inline code comments, or any other form of documentation)
7. ${GREEN}style:${RESET} (include modifications to indentation, spacing, or code styling guidelines)
8. ${GREEN}perf${RESET}: (involve optimizations, algorithm improvements, or any other modifications aimed at making the code faster or more efficient)
9. ${GREEN}refactor:${RESET} (include changes to variable names, file structure, code formatting, or any other modifications that enhance the code's structure)
10. ${GREEN}revert${RESET}: (undo changes made in a previous commit, bringing the codebase back to a previous state)
11. ${GREEN}test:${RESET} (include unit tests, integration tests, or any other changes related to testing the codebase)
12. ${GREEN}CHANGELOG:${RESET} (list of changes for multi-line messages w/o multiple commits)
13. ${GREEN}BREAKING CHANGE${RESET}: (a commit introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type)\n"
    read -rp "Enter your choice (1-8): " COMMIT_TYPE

    if [[ $COMMIT_TYPE =~ ^[1-8]$ ]]; then
        case $COMMIT_TYPE in
        1)
            TYPE="build"
            ;;
        2)
            TYPE="chore"
            ;;
        3)
            TYPE="ci"
            ;;
        4)
            TYPE="feat"
            ;;
        5)
            TYPE="fix"
            ;;
        6)
            TYPE="docs"
            ;;
        7)
            TYPE="style"
            ;;
        8)
            TYPE="perf"
            ;;
        9)
            TYPE="refactor"
            ;;
        10)
            TYPE="revert"
            ;;
        11)
            TYPE="test"
            ;;
        12)
            TYPE="CHANGELOG"
            ;;
        13)
            TYPE="BREAKING CHANGE"
            ;;
        esac

        read -rp "Enter the commit scope (optional): " SCOPE

        if [[ -z $SCOPE ]]; then
            echo -e "${YELLOW}Note: <SCOPE> is empty. Commit format will be: <type>: <subject>${RESET}\n"
        else
            echo -e "${YELLOW}Note: Commit format will be: <type>(<SCOPE>): <subject>${RESET}\n"
        fi

        while true; do
            read -rp "Enter the commit message: " SUBJECT

            if [[ -z $SCOPE ]]; then
                COMMIT_MESSAGE="\`$TYPE\`: $SUBJECT\n"
            else
                COMMIT_MESSAGE="\`$TYPE\`(\`$SCOPE\`): $SUBJECT\n"
            fi

            MESSAGES+=("$COMMIT_MESSAGE")

            read -rp "Do you want to add another commit message? (y/n): " CHOICE
            if [[ $CHOICE != "y" ]]; then
                break
            fi
        done

        echo -e "${YELLOW}" "${MESSAGES[@]}" "${RESET}"
        echo -e "${YELLOW}Commit messages to be executed:${RESET}"

        read -rp "Are you sure you want to execute these commit messages? (y/n): " CHOICE
        if [[ $CHOICE == "y" ]]; then
            # Format the commit message based on scope presence
            git commit -m "${MESSAGES[@]}"
            echo -e "${GREEN}Commits executed successfully!${RESET}"
        else
            echo -e "${RED}Commit execution canceled.${RESET}"
        fi

        echo -e "${GREEN}Commit Message:${RESET} $COMMIT_MESSAGE"
    else
        echo -e "${RED}Invalid input. Please enter a valid commit type.${RESET}"
        semantic_commit_messages
    fi
}

stash_changes() {
    echo -e "${GREEN}-------- Stash Changes --------${RESET}"
    git stash push
    echo -e "${GREEN}Changes stashed successfully!${RESET}"
}

apply_stash() {
    echo -e "${GREEN}-------- Apply Stash --------${RESET}"
    git stash apply
    echo -e "${GREEN}Stash applied successfully!${RESET}"
}

show_branches() {
    echo -e "${GREEN}-------- Branches Available --------${RESET}"
    git branch
}

create_branch() {
    echo -e "${GREEN}-------- Create Branch --------${RESET}"
    read -rp "Enter the branch name: " BRANCH_NAME
    echo -e "${GREEN}Creating branch '$BRANCH_NAME'${RESET}"
    git branch "$BRANCH_NAME"
    echo -e "${GREEN}Branch created successfully!${RESET}"
}

checkout_branch() {
    echo -e "${GREEN}-------- Branch Checkout --------${RESET}"
    read -rp "Enter the branch name to checkout: " BRANCH_NAME
    echo -e "${GREEN}Checking out branch '$BRANCH_NAME'${RESET}"
    git checkout "$BRANCH_NAME"
    echo -e "${GREEN}Branch '$BRANCH_NAME' checked out successfully!${RESET}"
}

delete_branch() {
    echo -e "${GREEN}-------- Delete Branch --------${RESET}"
    show_branches
    read -rp "Enter the branch name to delete: " BRANCH_NAME
    echo -e "${GREEN}Deleting branch '$BRANCH_NAME'${RESET}"
    git branch -D "$BRANCH_NAME"
    echo -e "${GREEN}Branch '$BRANCH_NAME' deleted successfully!${RESET}"
}

merge_branch() {
    echo -e "${GREEN}-------- Merege Branch --------${RESET}"
    show_branches
    read -rp "Enter the branch name to merge: " BRANCH_NAME
    echo -e "${GREEN}Merging branch '$BRANCH_NAME'${RESET}"
    git merge "$BRANCH_NAME"
    echo -e "${GREEN}Branch '$BRANCH_NAME' merged successfully!${RESET}"
}

tag_commit() {
    echo -e "${GREEN}-------- Tag Commit --------${RESET}"
    read -rp "Enter the tag name: " TAG_NAME
    echo -e "${GREEN}Tagging commit with '$TAG_NAME'${RESET}"
    git tag "$TAG_NAME"
    echo -e "${GREEN}Commit tagged with '$TAG_NAME' successfully!${RESET}"
}

exit_with_message() {
    echo -e "${GREEN}Exiting....${RESET}"
    exit 0
}

main_menu() {
    while true; do
        echo -e "${GREEN}---------- GIT AUTOMATE ----------${RESET}"
        echo -e "1. List Commits"
        echo -e "2. Create Simple Commit (non-semantic)"
        echo -e "3. Edit Commits"
        echo -e "4. Execute Commit"
        echo -e "5. Delete Commits"
        echo -e "6. Multiple Commit Messages (semantic)"
        echo -e "7. Stash Changes"
        echo -e "8. Apply Stash"
        echo -e "9. Show Branches"
        echo -e "10. Create Branch"
        echo -e "11. Checkout Branch"
        echo -e "12. Delete Branch"
        echo -e "13. Merge Branch"
        echo -e "14. Tag Commit"
        echo -e "15. Exit"

        read -rp "Enter your choice: " CHOICE

        case $CHOICE in
        1)
            display_commits
            ;;
        2)
            create_commit
            ;;
        3)
            edit_commits
            ;;
        4)
            execute_commit
            ;;
        5)
            delete_commits
            ;;
        6)
            semantic_commit_messages
            ;;
        7)
            stash_changes
            ;;
        8)
            apply_stash
            ;;
        9)
            show_branches
            ;;
        10)
            create_branch
            ;;
        11)
            checkout_branch
            ;;
        12)
            delete_branch
            ;;
        13)
            merge_branch
            ;;
        14)
            tag_commit
            ;;
        15)
            exit_with_message
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            ;;
        esac

        echo -e "${GREEN}----------------------------------------${RESET}"
        echo
    done
}

main_menu
