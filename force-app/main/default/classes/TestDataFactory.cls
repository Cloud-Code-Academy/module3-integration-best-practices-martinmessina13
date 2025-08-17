@isTest
public class TestDataFactory {
  /**
   * @description Creates a standard user and assigns a specific Permission Set.
   * @param permSetNames The API names of the Permission Sets to assign.
   * @return void
   */
  public static void createUserWithPermissionSets(List<String> permSetNames) {
    // A single profile is sufficient for all test users
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

    // Create a unique user to avoid conflicts in tests
    User u = new User(
      Alias = 'testusr',
      Email = 'testuser' + System.currentTimeMillis() + '@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser' + System.currentTimeMillis() + '@testorg.com'
    );
    insert u;

    // Assign the specified permission set
    List<PermissionSet> pss = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = :permSetNames
    ];

    List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();

    for (PermissionSet ps : pss) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = u.Id,
        PermissionSetId = ps.Id
      );
      psas.add(psa);
    }
    // Insert Permission Set Assignments
    insert psas;
  }
}
