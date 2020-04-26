import React, { useState } from 'react'

function OrderRow({ order, position, areas, updateOrders }) {
  return (
    <tr>
      <td>{position.type}</td>
      <td>{areas[position.area_id].name}</td>
      <td>{order.type}</td>
      <td>{order.from_id && areas[order.from_id].name}</td>
      <td>{order.to_id && areas[order.to_id].name}</td>
    </tr>
  );
}

export default function Orders(props) {
  const [orders, updateOrders] = useState(props.orders);

  return (
    <>
      <h2 className="subtitle is-5">Orders</h2>
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th>Unit</th>
            <th>Territory</th>
            <th>Order</th>
            <th>From</th>
            <th>To</th>
          </tr>
        </thead>
        <tbody>
          {orders.map((order) =>
            <OrderRow
              key={order.id}
              order={order}
              position={props.positions[order.position_id]}
              areas={props.areas}
              updateOrders={updateOrders}
            />
          )}
        </tbody>
      </table>
    </>
  );
}
