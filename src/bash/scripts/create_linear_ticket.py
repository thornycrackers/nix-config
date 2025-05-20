#!/usr/bin/env python3
import argparse
import os

import requests

LINEAR_API_KEY = os.environ["LINEAR_API_KEY"]
LINEAR_GRAPHQL_URL = "https://api.linear.app/graphql"


def _get_all_teams():
    """Function for going listing all the teams.

    Useful when trying to get the TEAM_ID
    """
    teams = []
    cursor = None
    first = 50
    while True:
        query = """
        query GetTeams($after: String, $first: Int!) {
            teams(after: $after, first: $first) {
                nodes {
                    id
                    name
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }
        """
        variables = {"after": cursor, "first": first}
        response = requests.post(
            LINEAR_GRAPHQL_URL,
            json={"query": query, "variables": variables},
            headers={"Authorization": f"{LINEAR_API_KEY}"},
        )
        data = response.json()
        teams_batch = data["data"]["teams"]["nodes"]
        teams.extend(teams_batch)  # Add teams from this batch
        # Check if there are more teams
        page_info = data["data"]["teams"]["pageInfo"]
        if not page_info["hasNextPage"]:
            break
        # Set the cursor for the next page
        cursor = page_info["endCursor"]
    return teams


def _get_label_id(team_id, label_name):
    """This function will get the id of a label.

    This works well enough for simple labels but I had issues trying to get
    nested label ids. I already had the label id I needed so I don't use this
    function right now, but it could be useful in the future.
    """
    query = """
    query GetLabels($teamId: String!) {
        team(id: $teamId) {
            labels {
                nodes {
                    id
                    name
                }
            }
        }
    }
    """
    variables = {"teamId": team_id}
    response = requests.post(
        LINEAR_GRAPHQL_URL,
        json={"query": query, "variables": variables},
        headers={"Authorization": LINEAR_API_KEY},
    )
    data = response.json()
    labels = data.get("data", {}).get("team", {}).get("labels", {}).get("nodes", [])
    for label in labels:
        if label["name"] == label_name:
            return label["id"]
    return None


def create_issue_with_label(team_id, title, description, label_id):
    query = """
    mutation CreateIssue($input: IssueCreateInput!) {
        issueCreate(input: $input) {
            success
            issue {
                id
                identifier
                title
                description
                labels {
                    nodes {
                        id
                        name
                    }
                }
            }
        }
    }
    """
    variables = {
        "input": {
            "teamId": team_id,
            "title": title,
            "description": description,
            "labelIds": [label_id],  # Use the labelId for the tag
        }
    }
    # Make the request to create the issue
    response = requests.post(
        LINEAR_GRAPHQL_URL,
        json={"query": query, "variables": variables},
        headers={"Authorization": LINEAR_API_KEY},
    )
    # Parse and return the response
    data = response.json()
    if data.get("data") and data["data"]["issueCreate"]["success"]:
        issue = data["data"]["issueCreate"]["issue"]
        return issue
    else:
        print("Failed to create issue:", data.get("errors", "Unknown error"))
        return None


def print_issue_url(issue, org_slug):
    """Print the url linking to the issue."""
    identifier = issue["identifier"]
    url = f"https://linear.app/{org_slug}/issue/{identifier}"
    print(url)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process team and label IDs.")
    parser.add_argument("--team_id", required=True, help="Team ID")
    parser.add_argument("--org_slug", required=True, help="Organization Slug")
    parser.add_argument("--label_id", required=True, help="Label ID")
    parser.add_argument("--title", required=True, help="Title of Issue")
    args = parser.parse_args()
    issue = create_issue_with_label(args.team_id, args.title, "todo", args.label_id)
    print_issue_url(issue, args.org_slug)
