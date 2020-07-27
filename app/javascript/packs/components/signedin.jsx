import React from 'react';
import PropTypes from 'prop-types';

import TabPanel from './tab-panel';
import InteractionTable from './interaction-table';
import Shoutout from './shoutout';

import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';


const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    backgroundColor: theme.palette.background.paper,
  },
}));

const Signedin = props => {
  const classes = useStyles();
  const [tabIndex, setTabIndex] = React.useState(0);

  return (
    <div className={classes.root}>
      <AppBar position="static">
        <Tabs value={tabIndex} onChange={(e, value) => setTabIndex(value)}>
          <Tab label="Interactions table" />
          <Tab label="Shoutout" />
        </Tabs>
      </AppBar>
      <TabPanel value={tabIndex} index={0}>
        <InteractionTable username={props.username} token={props.token}></InteractionTable>
      </TabPanel>
      <TabPanel value={tabIndex} index={1}>
        <Shoutout username={props.username} token={props.token}></Shoutout>
      </TabPanel>
    </div>
  );
};

Signedin.propTypes = {
  username: PropTypes.string,
  token: PropTypes.string,
};

export default Signedin;
