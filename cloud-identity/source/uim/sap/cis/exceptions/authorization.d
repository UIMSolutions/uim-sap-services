module uim.sap.cis.exceptions.authorization;

/**
  * CISAuthorizationException is thrown when a user does not have the necessary permissions to perform an action.
  *
  * This exception should be used to indicate that the user is authenticated but does not have the required authorization to access a resource or perform an operation.
  * It is important to differentiate this from authentication exceptions, which indicate that the user is not authenticated at all.
  * Example usage:
  * ```
  * if (!user.hasPermission("admin")) {
  *     throw new CISAuthorizationException("User does not have admin permissions.");
  * }
  * ```
  * This exception can be caught and handled to provide appropriate feedback to the user, such as displaying an error message or redirecting them to a different page.
  */
class CISAuthorizationException : CISException {
  this(string msg) {
    super(msg);
  }
}
