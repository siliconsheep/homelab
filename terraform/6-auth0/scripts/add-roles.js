exports.onExecutePostLogin = async (event, api) => {
  const namespace = 'https://siliconsheep';
  if (event.authorization) {
    api.idToken.setCustomClaim(`${namespace}/groups`, event.authorization.roles);
    api.accessToken.setCustomClaim(`${namespace}/groups`, event.authorization.roles);
  }
};