import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import Button from '@material-ui/core/Button';

import Loading from './loading';
import getShoutoutData from '../calls/get-shoutout-data';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  paper: {
    padding: theme.spacing(2),
    textAlign: 'center',
    color: theme.palette.text.secondary,
  },
}));

const Shoutout = props => {
  const [ isLoading, setIsLoading ] = useState(true);
  const [ shoutoutData, setShoutoutData ] = useState([]);

  useEffect(() => {
    (async () => {
      const response = await getShoutoutData(props.username, props.token);
      if (response.error) {
        setIsLoading(false);
        return;
      }
      setIsLoading(false);
      setShoutoutData(response.result);
    })();
  }, []);
  const classes = useStyles();

  let content = <span>Error</span>;
  if (isLoading) {
    content = <Loading></Loading>;
  } else if (shoutoutData) {
    content =
      <div className={classes.root}>
        <Grid container spacing={3}>
          {shoutoutData.map(shoutout => (
            <Grid item key={shoutout.login} xs={12} sm={6} md={3}>
              <Paper className={classes.paper}>
                <div className="shoutout-card">
                  <span>{shoutout.login}</span>
                  <img className="medium-avatar" src={shoutout.avatar_url} />
                  <Button variant="contained" color="primary">Send a shoutout</Button>
                </div>
              </Paper>
            </Grid>
          ))}
        </Grid>
      </div>;
  }

  return (
    <div>
      {content}
    </div>
  );
};

Shoutout.propTypes = {
  username: PropTypes.string,
  token: PropTypes.string,
};

export default Shoutout;
