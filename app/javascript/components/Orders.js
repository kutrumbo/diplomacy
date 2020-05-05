import React, { useState } from 'react'
import { capitalize, filter, find, first, isEmpty, isEqual, keys, last, map, sortBy, startCase, uniqWith, values } from 'lodash';

function validFromOptions(order, validOrder, position, areas, coasts) {
  if (order.type === 'support' || order.type === 'convoy') {
    return sortOptions(uniqWith(map(validOrder[order.type], detail => first(detail)), isEqual), areas, coasts);
  } else {
    return [[position.area_id, position.coast_id]];
  }
}

function validToOptions(order, validOrder, position, areas, coasts) {
  if (['hold', 'build_army', 'no_build'].includes(order.type)) {
    return [[position.area_id, position.coast_id]];
  }
  const orderDetails = validOrder[order.type];
  if (['move', 'retreat', 'build_fleet'].includes(order.type)) {
    return sortOptions(map(orderDetails, detail => last(detail)), areas, coasts);
  }
  const validPaths = filter(orderDetails, detail => isEqual(first(detail), [order.from_id, order.from_coast_id]));
  return sortOptions(uniqWith(map(validPaths, detail => last(detail)), isEqual), areas, coasts);
}

function sortOptions(areaCoastPairs, areas, coasts) {
  return sortBy(areaCoastPairs, areaCoastPair => areaLabel(areaCoastPair, areas, coasts));
}

function areaLabel(areaCoastPair, areas, coasts) {
  const areaName = areas[areaCoastPair[0]].name
  const coastDirection = areaCoastPair[1] && coasts[areaCoastPair[1]].direction;
  const coastName = coastDirection && `${coastDirection.charAt(0).toUpperCase()}C`
  return coastName ? `${areaName} (${coastName})` : areaName;
}

function OrderRow({ areas, coasts, error, order, position, setError, updateOrders, validOrder }) {
  const fromOptions = validFromOptions(order, validOrder, position, areas, coasts);
  const toOptions = validToOptions(order, validOrder, position, areas, coasts);

  const handleSelect = (event) => {
    setError(null);
    const { name, value } = event.target;
    let updatedOrder = order;
    if (name === 'type') {
      updatedOrder[name] = value;
    } else {
      const areaCoastPair = JSON.parse(value);
      updatedOrder[`${name}_id`] = areaCoastPair[0];
      updatedOrder[`${name}_coast_id`] = areaCoastPair[1];
    }
    if (name === 'type') {
      const updatedFromOptions = validFromOptions(updatedOrder, validOrder, position, areas, coasts);
      const defaultValue = (updatedFromOptions.length === 1) ? updatedFromOptions[0] : [null, null];
      updatedOrder = { ...updatedOrder, from_id: defaultValue[0], from_coast_id: defaultValue[1] };
    }
    if (name !== 'to') {
      const updatedToOptions = validToOptions(updatedOrder, validOrder, position, areas, coasts);
      const defaultValue = (updatedToOptions.length === 1) ? updatedToOptions[0] : [null, null];
      updatedOrder = { ...updatedOrder, to_id: defaultValue[0], to_coast_id: defaultValue[1] };
    }
    updateOrders(prevOrders => ({
      ...prevOrders,
      [order.id]: updatedOrder,
    }));
  }

  const handleCheck = (event) => {
    const checked = event.target.checked;
    updateOrders(prevOrders => ({
      ...prevOrders,
      [order.id]: { ...order, confirmed: checked }
    }));
  }

  const showFrom = ['convoy', 'support'].includes(order.type);
  const buildFleetToCoast = order.type === 'build_fleet' && toOptions.length > 1;
  const showTo = ['convoy', 'move', 'retreat', 'support'].includes(order.type) || buildFleetToCoast;

  return (
    <tr>
      <td>{capitalize(position.type)}</td>
      <td>{areaLabel([position.area_id, position.coast_id], areas, coasts)}</td>
      <td>
        <div className={`select is-rounded is-small${error ? ' is-danger' : ''}`}>
          <select value={order.type} name="type" onChange={handleSelect}>
            {keys(validOrder).map(orderType =>
              <option key={orderType} value={orderType}>{startCase(orderType)}</option>
            )}
          </select>
        </div>
      </td>
      <td>
        {showFrom &&
          <div className={`select is-small${error ? ' is-danger' : ''}`}>
            <select
              className="select-region"
              value={JSON.stringify([order.from_id, order.from_coast_id])}
              name="from"
              onChange={handleSelect}>
              {(order.from_id === null) && <option value="[null,null]" disabled>---</option>}
              {fromOptions.map(from =>
                <option key={from} value={JSON.stringify(from)}>{areaLabel(from, areas, coasts)}</option>
              )}
            </select>
          </div>
        }
      </td>
      <td>
        {showTo &&
          <div className={`select is-small${error ? ' is-danger' : ''}`}>
            <select
              className="select-region"
              value={JSON.stringify([order.to_id, order.to_coast_id])}
              name="to"
              onChange={handleSelect}>
              {(order.to_id === null) && <option value="[null,null]" disabled>---</option>}
              {toOptions.map(to =>
                <option key={to} value={JSON.stringify(to)}>{areaLabel(to, areas, coasts)}</option>
              )}
            </select>
          </div>
        }
      </td>
      <td>
        <label className="checkbox checkbox-confirm">
          <input type="checkbox" checked={order.confirmed} onChange={handleCheck} />
        </label>
      </td>
    </tr>
  );
}

export default function Orders(props) {
  const csrfToken = document.querySelector('[name=csrf-token]').content;
  const [orders, updateOrders] = useState(props.orders);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const submitOrders = (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    fetch(`/games/${props.user_game.game_id}/orders`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({ orders }),
      credentials: 'same-origin',
    })
    .then(response => {
      if (!response.ok) {
        throw response;
      }
      return response.json()
    })
    .then(json => {
      location.reload();
    })
    .catch(error => error.json())
    .then(errorJson => {
      setLoading(false);
      setError(errorJson);
    });
  }

  if (isEmpty(orders)) {
    return (
      <>
        <h2 className="subtitle is-5">No possible orders</h2>
      </>
    )
  }

  return (
    <div className="table-container">
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th>Unit</th>
            <th>Territory</th>
            <th>Order</th>
            <th className="order-region-column">From</th>
            <th className="order-region-column">To</th>
            <th>Confirm</th>
          </tr>
        </thead>
        <tbody>
          {values(orders).map(order =>
            <OrderRow
              areas={props.areas}
              coasts={props.coasts}
              error={error && error.validations[order.id]}
              key={order.id}
              order={order}
              position={props.positions[order.position_id]}
              setError={setError}
              updateOrders={updateOrders}
              validOrder={props.valid_orders[order.position_id]}
            />
          )}
          <tr>
            <td colSpan="5">
              {error && <div className="notification is-warning is-light">{error.message}</div>}
            </td>
            <td>
              <button
                className={`button is-primary${loading ? ' is-loading' : ''}`}
                onClick={submitOrders}>
                Save
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}
