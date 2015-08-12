////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private

extension Realm {
  /**
  A `Configuration` is used to describe the different options used to
  create a `Realm` instance.
  */
  public struct Configuration {

      // MARK: Default Configuration

      /// Returns the default Configuration used to create Realms when no other
      /// configuration is explicitly specified (i.e. `Realm()`).
      public static var defaultConfiguration: Configuration {
          get {
              return fromRLMConfiguration(RLMConfiguration.defaultConfiguration())
          }
          set {
              RLMConfiguration.setDefaultConfiguration(newValue.rlmConfiguration)
          }
      }

      // MARK: Initialization

      /**
      Initializes a `Configuration`, suitable for creating new `Realm` instances.

      :param: path               The path to the realm file.
      :param: inMemoryIdentifier A string used to identify a particular in-memory Realm.
      :param: encryptionKey      64-byte key to use to encrypt the data.
      :param: readOnly           Whether the Realm is read-only (must be true for read-only files).
      :param: schemaVersion      The current schema version.
      :param: migrationBlock     The block which migrates the Realm to the current version.

      :returns: An initialized `Configuration`.
      */
      public init(path: String? = RLMConfiguration.defaultRealmPath(),
          inMemoryIdentifier: String? = nil,
          encryptionKey: NSData? = nil,
          readOnly: Bool = false,
          schemaVersion: UInt64 = 0,
          migrationBlock: MigrationBlock? = nil) {
              self.path = path
              self.inMemoryIdentifier = inMemoryIdentifier
              self.encryptionKey = encryptionKey
              self.readOnly = readOnly
              self.schemaVersion = schemaVersion
              self.migrationBlock = migrationBlock
      }

      // MARK: Configuration Properties

      /// The path to the realm file.
      /// Mutually exclusive with `inMemoryIdentifier`.
      public var path: String?  {
          set {
              if newValue != nil {
                  inMemoryIdentifier = nil
              }
              _path = newValue
          }
          get {
              return _path
          }
      }

      private var _path: String?

      /// A string used to identify a particular in-memory Realm.
      /// Mutually exclusive with `path`.
      public var inMemoryIdentifier: String?  {
          set {
              if newValue != nil {
                  path = nil
              }
              _inMemoryIdentifier = newValue
          }
          get {
              return _inMemoryIdentifier
          }
      }

      private var _inMemoryIdentifier: String? = nil

      /// 64-byte key to use to encrypt the data.
      public var encryptionKey: NSData? {
          set {
              _encryptionKey = RLMRealmValidatedEncryptionKey(newValue)
          }
          get {
              return _encryptionKey
          }
      }

      private var _encryptionKey: NSData? = nil

      /// Whether the Realm is read-only (must be true for read-only files).
      public var readOnly: Bool = false

      /// The current schema version.
      public var schemaVersion: UInt64 = 0

      /// The block which migrates the Realm to the current version.
      public var migrationBlock: MigrationBlock? = nil

      // MARK: Private Methods

      internal var rlmConfiguration: RLMConfiguration {
          let configuration = RLMConfiguration()
          configuration.path = self.path
          configuration.inMemoryIdentifier = self.inMemoryIdentifier
          configuration.encryptionKey = self.encryptionKey
          configuration.readOnly = self.readOnly
          configuration.schemaVersion = self.schemaVersion
          configuration.migrationBlock = self.migrationBlock.map { accessorMigrationBlock($0) }
          return configuration
      }

      internal static func fromRLMConfiguration(rlmConfiguration: RLMConfiguration) -> Configuration {
          return Configuration(path: rlmConfiguration.path,
              inMemoryIdentifier: rlmConfiguration.inMemoryIdentifier,
              encryptionKey: rlmConfiguration.encryptionKey,
              readOnly: rlmConfiguration.readOnly,
              schemaVersion: UInt64(rlmConfiguration.schemaVersion),
              migrationBlock: map(rlmConfiguration.migrationBlock) { rlmMigration in
                  return { migration, schemaVersion in
                      rlmMigration(migration.rlmMigration, schemaVersion)
                  }
              })
      }
  }
}

// MARK: Printable

extension Realm.Configuration: Printable {
    /// Returns a human-readable description of the configuration.
    public var description: String {
        return gsub("\\ARLMConfiguration", "Configuration", rlmConfiguration.description) ?? ""
    }
}
