/** 
 * @param {number} seconds
 * @returns {Promise<void>}
 */
export const sleep = async (seconds) => {
  return await new Promise((resolve) =>
    setTimeout(() => resolve(), seconds * 1000)
  );
};
