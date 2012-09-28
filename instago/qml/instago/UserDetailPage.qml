// *************************************************** //
// User Detail Page
//
// The user profile page shows the personal information
// about a specific user.
// Note that this is not the page that shows the
// profile of the currently logged in user.
// *************************************************** //

import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1

import "js/globals.js" as Globals
import "js/authentication.js" as Authentication
import "js/userdata.js" as UserDataScript
import "js/relationships.js" as UserRelationshipScript

Page {
    // use the detail view toolbar
    tools: profileToolbar

    // lock orientation to portrait mode
    orientationLock: PageOrientation.LockPortrait

    // this holds the user id of the respective user
    // the property will be filled by the calling page
    property string userId: "";

    Component.onCompleted: {
        // load the users profile
        UserDataScript.loadUserProfile(userId);

        // show follow button if the user is logged in
        if (Authentication.isAuthorized())
        {
            userprofileFollowUser.visible = true;
        }
    }

    // standard header for the current page
    Header {
        id: pageHeader
        source: "img/top_header.png"
        text: qsTr("")
    }

    // standard notification area
    NotificationArea {
        id: notification

        visibilitytime: 1500

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
    }


    // header with the user metadata
    UserMetadata {
        id: userprofileMetadata;

        anchors {
            top: pageHeader.bottom;
            topMargin: 10;
            left: parent.left;
            right: parent.right;
        }

        visible: false

        onProfilepictureClicked: {
            userprofileGallery.visible = false;
            userprofileBioContainer.visible = true;
            userprofileContentHeadline.text = "User Bio";
        }

        onImagecountClicked: {
            // user photos are only available for logged in users
            if (Authentication.isAuthorized())
            {
                userprofileBioContainer.visible = false;
                userprofileContentHeadline.text = "User Photos";
                UserDataScript.loadUserImages(userId, 0);
                userprofileGallery.visible = true;
            }
        }

        onFollowersClicked: {

        }

        onFollowingClicked: {

        }
    }


    // container headline
    // container is only visible if user is authenticated
    Text {
        id: userprofileContentHeadline

        anchors {
            top: userprofileMetadata.bottom
            topMargin: 10
            left: parent.left
            leftMargin: 10
            right: parent.right;
            rightMargin: 10
        }

        height: 30
        visible: false

        font.family: "Nokia Pure Text Light"
        font.pixelSize: 25
        wrapMode: Text.Wrap

        // content container headline
        // text will be given by the content switchers
        text: "User Bio"
    }


    // bio of the user
    // this also contains the follow buttons
    Rectangle {
        id: userprofileBioContainer

        anchors {
            top: userprofileContentHeadline.bottom
            topMargin: 10
            left: parent.left
            right: parent.right;
            bottom: parent.bottom
        }

        visible: false

        // no background color
        color: "transparent"

        // bio of the user
        Text {
            id: userprofileBio

            anchors {
                top: userprofileBioContainer.top
                topMargin: 10
                left: parent.left
                leftMargin: 10
                right: parent.right;
                rightMargin: 10
            }

            font.family: "Nokia Pure Text Light"
            font.pixelSize: 25
            wrapMode: Text.Wrap

            // user bio
            // text will be given by the js function
            // beware that the length is not limited by Instagram
            // this might be LONG!
            text: ""
        }


        // follow button
        Button {
            id: userprofileFollowUser

            anchors {
                left: parent.left;
                leftMargin: 30;
                right: parent.right;
                rightMargin: 30;
                top: userprofileBio.bottom;
                topMargin: 30;
            }

            visible: false
            text: "Follow"

            onClicked: {
                notification.text = "Hey, you found a new friend!";
                notification.show();

                UserRelationshipScript.setRelationship(userId, "follow");

                userprofileFollowUser.visible = false;
                userprofileUnfollowUser.visible = true;
            }
        }


        // unfollow button
        Button {
            id: userprofileUnfollowUser

            anchors {
                left: parent.left;
                leftMargin: 30;
                right: parent.right;
                rightMargin: 30;
                top: userprofileBio.bottom;
                topMargin: 30;
            }

            visible: false
            text: "Unfollow"

            onClicked: {
                notification.text = "Sorry, but sometimes it doesn't work out";
                notification.show();

                UserRelationshipScript.setRelationship(userId, "unfollow");

                userprofileUnfollowUser.visible = false;
                userprofileFollowUser.visible = true;
            }
        }
    }


    // gallery of user images
    // container is only visible if user is authenticated
    ImageGallery {
        id: userprofileGallery;

        anchors {
            top: userprofileContentHeadline.bottom
            topMargin: 10;
            left: parent.left;
            right: parent.right;
            bottom: parent.bottom;
        }

        visible: false

        onItemClicked: {
            // console.log("Image tapped: " + imageId);
            pageStack.push(Qt.resolvedUrl("ImageDetailPage.qml"), {imageId: imageId});
        }

        onListBottomReached: {
            if (paginationNextMaxId !== "")
            {
                UserDataScript.loadUserImages(userId, paginationNextMaxId);
            }
        }
    }


    // show the loading indicator as long as the page is not ready
    BusyIndicator {
        id: loadingIndicator

        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: "large" }

        running:  true
        visible: true
    }


    // error indicator that is shown when a network error occured
    NetworkErrorMessage {
        id: networkErrorMesage

        anchors {
            top: pageHeader.bottom;
            topMargin: 3;
            left: parent.left;
            right: parent.right;
            bottom: parent.bottom;
        }

        visible: false

        onMessageTap: {
            // console.log("Refresh clicked")
            networkErrorMesage.visible = false;
            userprofileMetadata.visible = false;
            userprofileContentHeadline.visible = false;
            userprofileBioContainer.visible = false;
            loadingIndicator.running = true;
            loadingIndicator.visible = true;
            UserDataScript.loadUserProfile(userId);
        }
    }


    // toolbar for the detail page
    ToolBarLayout {
        id: profileToolbar
        visible: false

        // jump back to the detail image
        ToolIcon {
            iconId: "toolbar-back";
            onClicked: {
                pageStack.pop();
            }
        }
    }
}
