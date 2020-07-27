import axios from 'axios';

export default async (username, token) => {
  try {
    const response = await axios.post('/api/shoutout-data', {
      username: username,
      token: token,
    });
    return { result: response.data };
  } catch (e) {
    return { error: e };
  }
};