exports.onExecutePostLogin = async (event, api) => {
  const ManagementClient = require("auth0").ManagementClient;
  const namespace = 'https://siliconsheep';

  const { AUTH0_DOMAIN, AUTH0_CLIENT_ID, AUTH0_CLIENT_SECRET } = event.secrets;

  // Debug
  console.log(event);

  // Apply to unlinked account only
  if (event.user.identities.some((id) => id.isSocial === false)) {
    console.log('Account already linked, skipping action')
    return
  }

  const management = new ManagementClient({
    domain: AUTH0_DOMAIN,
    clientId: AUTH0_CLIENT_ID,
    clientSecret: AUTH0_CLIENT_SECRET
  });

  // Check if there already is an account with this email address
  let users = await management.getUsersByEmail(event.user.email);
  let dbUser = users.find((u) => u.user_id.startsWith('auth0|'));

  // If there isn't any database account with this email address, 
  // try to find a database account with this email address listed as additional email address.
  if(!dbUser) {
    users = await management.getUsers({
      search_engine: 'v3', 
      q: `user_metadata.additional_emails:"${event.user.email}"`
    });
    dbUser = users.find((u) => u.user_id.startsWith('auth0|'));

    // If there isn't any database account with this email address listed as additional email address,
    // deny access
    if(!dbUser) {
      api.access.deny('User not found in database')
    }
  }

  const appMetadata = dbUser.app_metadata || {};
  const userMetadata = dbUser.user_metadata || {};

  // Write updated metadata to the primary account
  try {
    // Merge in user and app metadata from the other account.
    Object.assign(appMetadata, event.user.app_metadata);
    Object.assign(userMetadata, event.user.user_metadata);

    await management.users.updateAppMetadata({id: dbUser.user_id}, appMetadata);
    await management.users.updateUserMetadata({id: dbUser.user_id}, userMetadata);
    console.log(`Merged user_data and app_data from ${event.user.user_id} into ${dbUser.user_id} | email: ${dbUser.email}`);
  } catch (e) {
    console.log(e)
    api.access.deny('Failure to merge app_data and user_data')
    return
  }

  // Link user accounts
  try {
    await management.users.link(dbUser.user_id, {
      user_id: event.user.user_id,
      provider: event.user.identities[0].provider,
    });
    console.log(`Succesfully linked ${event.user.user_id} with ${dbUser.user_id} | email: ${dbUser.email}`);
  } catch (e) {
    console.log(e)
    api.access.deny('Failure to link accounts')
    return
  }

  // After the account is linked, we no longer have the second account, so we'll have to deny access the first time the user logs in.
  api.access.deny('First time login successful. Please log in again')
};