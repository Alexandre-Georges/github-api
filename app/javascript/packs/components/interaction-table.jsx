import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import Loading from './loading';
import getInteractions from '../calls/get-interactions';

import { makeStyles } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableSortLabel from '@material-ui/core/TableSortLabel';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';

import 'date-fns';
import subDays from 'date-fns/subDays';
import Grid from '@material-ui/core/Grid';
import DateFnsUtils from '@date-io/date-fns';
import {
  MuiPickersUtilsProvider,
  KeyboardDatePicker,
} from '@material-ui/pickers';

const useStyles = makeStyles({
  table: {
    minWidth: 650,
  },
});

const comparator = (order, a, b, prop) => {
  const factor = order === 'asc' ? 1 : -1;
  return factor * (a[prop] < b[prop] ? -1 : 1);
};

const InteractionTable = props => {
  const [ isLoading, setIsLoading ] = useState(true);

  const [ from, setFrom ] = useState(subDays(new Date(), 7));
  const [ to, setTo ] = useState(new Date());
  const [ interactions, setInteractions ] = useState([]);

  const [ orderBy, setOrderBy ] = useState('login');
  const [ order, setOrder ] = useState('asc');

  useEffect(() => {
    (async () => {
      const response = await getInteractions(props.username, props.token, from, to);
      if (response.error) {
        setIsLoading(false);
        return;
      }
      setIsLoading(false);
      setInteractions(response.result);
    })();
  }, [ from, to ]);

  const classes = useStyles();

  let content = <span>Error</span>;
  if (isLoading) {
    content = <Loading></Loading>;
  } else if (interactions) {
    const sortInteractions = name => {
      setOrder(orderBy === name && order === 'asc' ? 'desc' : 'asc');
      setOrderBy(name);
    };
    const createTableHeader = (label, name, orderBy, order, align) => {
      let labelElement = label;
      if (name) {
        const isSorted = orderBy === name;
        labelElement = <TableSortLabel
          active={isSorted}
          direction={isSorted ? order : 'asc'}
          onClick={() => sortInteractions(name)}
        >
          {label}
        </TableSortLabel>;
      }
      return <TableCell sortDirection={orderBy === name ? order : false} align={align}>
        {labelElement}
      </TableCell>;
    };

    content =
      <div>
        <MuiPickersUtilsProvider utils={DateFnsUtils}>
          <Grid container justify="space-around">
            <KeyboardDatePicker
              disableToolbar
              variant="inline"
              format="MM/dd/yyyy"
              margin="normal"
              id="from"
              label="From"
              value={from}
              onChange={setFrom}
              KeyboardButtonProps={{
                'aria-label': 'change date',
              }} />
            <KeyboardDatePicker
              disableToolbar
              variant="inline"
              format="MM/dd/yyyy"
              margin="normal"
              id="to"
              label="To"
              value={to}
              onChange={setTo}
              KeyboardButtonProps={{
                'aria-label': 'change date',
              }} />
          </Grid>
        </MuiPickersUtilsProvider>
        <div>
          <TableContainer component={Paper}>
            <Table className={classes.table} aria-label="simple table">
              <TableHead>
                <TableRow>
                  {createTableHeader('Login', 'login', orderBy, order, 'inherit')}
                  {createTableHeader('Avatar', '', orderBy, order, 'center')}
                  {createTableHeader('Interaction Type', 'type', orderBy, order, 'right')}
                  {createTableHeader('Interaction Count', 'count', orderBy, order, 'right')}
                </TableRow>
              </TableHead>
              <TableBody>
                {interactions.sort((a, b) => comparator(order, a, b, orderBy)).map(interaction => (
                  <TableRow key={`${interaction.login}-${interaction.type}`}>
                    <TableCell component="th" scope="row">{interaction.login}</TableCell>
                    <TableCell align="center"><img className="small-avatar" src={interaction.avatar_url} ></img></TableCell>
                    <TableCell align="right">{interaction.type}</TableCell>
                    <TableCell align="right">{interaction.count}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </div>
      </div>;
  }

  return (
    <div>
      {content}
    </div>
  );
};

InteractionTable.propTypes = {
  username: PropTypes.string,
  token: PropTypes.string,
};

export default InteractionTable;
