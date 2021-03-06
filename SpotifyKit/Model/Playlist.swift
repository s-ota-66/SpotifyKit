//
//  Playlist.swift
//  SpotifyKit
//
//  Created by Alexander Havermale on 7/25/17.
//  Copyright © 2018 Alex Havermale.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// A Spotify playlist.
///
/// - SeeAlso: The Web API [Simplified](https://developer.spotify.com/documentation/web-api/reference/object-model/#playlist-object-simplified) and [Full](https://developer.spotify.com/documentation/web-api/reference/object-model/#playlist-object-full) Playlist objects.
public struct SKPlaylist: JSONDecodable {
    
    /// An enum representing the expected `type` value for a playlist object.
    private enum ResourceType: String, Codable { case playlist }

    // MARK: - Simplified Playlist Properties
    
    /// `true` if the owner allows other users to modify the playlist.
    public let isCollaborative: Bool
    
    /// Known external URLs for this playlist.
    public let externalURLs: [String: URL]

    /// A link to the Web API endpoint providing full details of the playlist.
    public let url: URL
    
    /// The [Spotify ID](https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids) for the playlist.
    public let id: String
    
    /// Images for the playlist. The array may be empty or contain up to three images. The images are returned by size in descending order. See [Working with Playlists](https://developer.spotify.com/documentation/general/guides/working-with-playlists/).
    /// - Note: If returned, the source URL for the image (`url`) is temporary and will expire in less than a day.
    public let images: [SKImage]
    
    /// The name of the playlist.
    public let name: String
    
    /// The user who owns the playlist.
    public let owner: SKUser
    
    /// The playlist's public/private status: `true` the playlist is public, `false` the playlist is private, `nil` the playlist status is not relevant. For more about public/private status, see [Working with Playlists](https://developer.spotify.com/documentation/general/guides/working-with-playlists/).
    public let isPublic: Bool?
    
    /// The version identifier for the current playlist. Can be supplied in other requests to target a specific playlist version.
    public let snapshotID: String
    
    /// A link to the Web API endpoint where full details of the playlist's tracks can be retrieved.
    public let tracksURL: URL
    
    /// The total number of tracks in the playlist.
    public let totalTracks: Int
    
    /// The [Spotify URI](https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids) for the playlist.
    public let uri: String
    
    /// The resource object type: `"playlist"`.
    private let type: ResourceType
    
    // MARK: - Full Playlist Properties
    
    /// A collection containing information about the tracks of the playlist.
    public let tracks: Page<SKPlaylistTrack>?
    
    /// The playlist description. Only returned for modified, verified playlists, otherwise `nil`.
    public let userDescription: String?
    
    /// Information about the followers of the playlist.
    public let followers: SKFollowers?
}

// MARK: - Custom Decoding

extension SKPlaylist: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case isCollaborative = "collaborative"
        case userDescription = "description"
        case externalURLs = "external_urls"
        case followers
        case url = "href"
        case id
        case images
        case name
        case owner
        case isPublic = "public"
        case snapshotID = "snapshot_id"
        case tracks
        case type
        case uri
    }
    
    /// Used for simplified playlist objects, when the entire collection of tracks is not returned.
    private struct SimplifiedTracks: Decodable {
        
        /// A link to the Web API endpoint where full details of the playlist's tracks can be retrieved.
        public let url: URL
        
        /// The total number of tracks in the playlist.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case url = "href"
            case total
        }
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Verify the type of object we're decoding first:
        type = try values.decode(ResourceType.self, forKey: .type)

        isCollaborative = try values.decode(Bool.self, forKey: .isCollaborative)
        externalURLs = try values.decode([String: URL].self, forKey: .externalURLs)
        url = try values.decode(URL.self, forKey: .url)
        uri = try values.decode(String.self, forKey: .uri)
        id = try values.decode(String.self, forKey: .id)
        images = try values.decode([SKImage].self, forKey: .images)
        name = try values.decode(String.self, forKey: .name)
        owner = try values.decode(SKUser.self, forKey: .owner)
        isPublic = try values.decodeIfPresent(Bool.self, forKey: .isPublic)
        snapshotID = try values.decode(String.self, forKey: .snapshotID)
        userDescription = try values.decodeIfPresent(String.self, forKey: .userDescription)
        followers = try values.decodeIfPresent(SKFollowers.self, forKey: .followers)
        
        // Handle both simplified and full "tracks" objects:
        tracks = try? values.decode(Page<SKPlaylistTrack>.self, forKey: .tracks)
        tracksURL = try tracks?.url ?? values.decode(SimplifiedTracks.self, forKey: .tracks).url
        totalTracks = try tracks?.total ?? values.decode(SimplifiedTracks.self, forKey: .tracks).total
    }
}

// MARK: - Expandable Conformance

extension SKPlaylist: Expandable {
    
    public var isSimplified: Bool {
        return
            userDescription == nil &&
            followers == nil &&
            tracks == nil
    }
}

// MARK: - Featured Playlists

/// A structure containing a paginated collection of featured playlists, accompanied by a localized message from Spotify.
public struct SKFeaturedPlaylists: JSONDecodable {
    
    /// An accompanying localized message from Spotify.
    public let localizedMessage: String
    
    /// A list of featured playlists.
    public let playlists: Page<SKPlaylist>
    
    private enum CodingKeys: String, CodingKey {
        case localizedMessage = "message"
        case playlists
    }
}
