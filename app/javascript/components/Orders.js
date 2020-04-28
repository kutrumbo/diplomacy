import React, { useState } from 'react'
import { capitalize, filter, first, keys, last, map, sortBy, uniq, values } from 'lodash';

function validFromOptions(order, validOrder, position) {
  if (order.type === 'support' || order.type === 'convoy') {
    return sortBy(uniq(map(validOrder[order.type], detail => first(detail))));
  } else {
    return [position.area_id];
  }
}

function validToOptions(order, validOrder, position) {
  if (order.type === 'hold') {
    return [position.area_id];
  }
  const orderDetails = validOrder[order.type];
  if (order.type === 'move') {
    return sortBy(map(orderDetails, detail => last(detail)));
  }
  const validPaths = filter(orderDetails, detail => first(detail) === order.from_id);
  return sortBy(uniq(map(validPaths, detail => last(detail))));
}

function OrderRow({ areas, error, order, position, updateOrders, validOrder }) {
  const fromOptions = validFromOptions(order, validOrder, position);
  const toOptions = validToOptions(order, validOrder, position);

  const handleSelect = (event) => {
    const { name, value } = event.target;
    let updatedOrder = { ...order, [name]: name === 'type' ? value : parseInt(value, 10) };
    if (name === 'type') {
      const updatedFromOptions = validFromOptions(updatedOrder, validOrder, position);
      const defaultValue = (updatedFromOptions.length === 1) ? updatedFromOptions[0] : '';
      updatedOrder = { ...updatedOrder, from_id: defaultValue };
    }
    if (name !== 'to_id') {
      const updatedToOptions = validToOptions(updatedOrder, validOrder, position);
      const defaultValue = (updatedToOptions.length === 1) ? updatedToOptions[0] : '';
      updatedOrder = { ...updatedOrder, to_id: defaultValue };
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

  const showFrom = order.type === 'support' || order.type === 'convoy';
  const showTo = order.type !== 'hold';

  return (
    <tr>
      <td>{capitalize(position.type)}</td>
      <td>{areas[position.area_id].name}</td>
      <td>
        <div className={`select is-rounded is-small${error ? ' is-danger' : ''}`}>
          <select value={order.type} name="type" onChange={handleSelect}>
            {keys(validOrder).map(orderType =>
              <option key={orderType} value={orderType}>{orderType.toUpperCase()}</option>
            )}
          </select>
        </div>
      </td>
      <td>
        {showFrom &&
          <div className={`select is-small${error ? ' is-danger' : ''}`}>
            <select
              className="select-region"
              value={order.from_id}
              name="from_id"
              onChange={handleSelect}>
              {(order.from_id === '') && <option value="" disabled>---</option>}
              {fromOptions.map(fromId =>
                <option key={fromId} value={fromId}>{areas[fromId].name}</option>
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
              value={order.to_id}
              name="to_id"
              onChange={handleSelect}>
              {(order.to_id === '') && <option value="" disabled>---</option>}
              {toOptions.map(toId =>
                <option key={toId} value={toId}>{areas[toId].name}</option>
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
      setLoading(false);
    })
    .catch(error => error.json())
    .then(errorJson => {
      setLoading(false);
      setError(errorJson);
    });
  }

  return (
    <>
      <h2 className="subtitle is-5 is-pulled-left">Orders</h2>
      <button
        className={`button is-primary is-pulled-right${loading ? ' is-loading' : ''}`}
        onClick={submitOrders}>
        Submit
      </button>
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
              error={error && error.validations[order.id]}
              key={order.id}
              order={order}
              position={props.positions[order.position_id]}
              updateOrders={updateOrders}
              validOrder={props.valid_orders[order.position_id]}
            />
          )}
        </tbody>
      </table>
      {error && <div className="notification is-warning is-light">{error.message}</div>}
    </>
  );
}
