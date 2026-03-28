module uim.sap.docmgmtintegration.interfaces.repositoryconnector;

interface IRepositoryConnector {
  /// Test connectivity to the repository.
  bool ping();

  /// Retrieve repository information.
  Repository info();

  /// The repository identifier.
  string repositoryId();

  /// The owning tenant identifier.
  UUID tenantId();
}