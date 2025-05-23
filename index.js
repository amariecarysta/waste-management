const express = require('express');
const { engine } = require('express-handlebars');
const path = require('path');
const pool = require('./db-connector');


const app = express();


app.use(express.urlencoded({ extended: true }));


app.use(express.static(path.join(__dirname, 'public')));


app.engine('hbs', engine({
  extname: '.hbs',
  layoutsDir: path.join(__dirname, 'views/layouts'),
  defaultLayout: 'main'   
}));

app.set('view engine', 'hbs');
app.set('views', path.join(__dirname, 'views'));




app.get('/', (req, res) => {
  res.render('index', {
    title:  'Waste Management Dashboard'   
  });
});

// RESET Database Route
app.get('/reset', (req, res) => {
  res.render('reset', { 
    title: 'Reset Database',
    warning: 'This will delete all data and reset the database'
  });
});

app.post('/reset', async (req, res, next) => {
  try {
    // Call the stored procedure
    await pool.query('CALL ResetDatabase()');
    
    // Render success page
    res.render('reset-success', { 
      title: 'Database Reset',
      message: 'Database has been successfully reset!'
    });
  } catch (err) {
    console.error('Reset error:', err);
    res.render('error', {
      title: 'Reset Failed',
      message: 'Failed to reset database: ' + err.message
    });
  }
});

app.get('/customers', async (req, res, next) => {
  try {
    const [customers] = await pool.query(`
      SELECT customerID, name, address, type, contactNumber, routeID
        FROM customers
    `);
    res.render('customers-list', { title: 'Customers', customers });
  } catch (err) {
    next(err);
  }
});

//FACILITIES

app.get('/facilities', async (req, res, next) => {
  try {
    const [facilities] = await pool.query(`
      SELECT facilityID, name, location, facilityType
        FROM disposalFacilities
    `);
    res.render('facilities-list', { title: 'Facilities', facilities });
  } catch (err) {
    next(err);
  }
});

app.get('/facilities/new', (req, res) => {
  res.render('facilities-new', { title:'New Facility' })
})

app.post('/facilities/new', async (req, res) => {
  const { name, location, facilityType } = req.body
  await pool.query(
    `INSERT INTO disposalFacilities (name,location,facilityType)
      VALUES (?,?,?)`,
    [ name, location, facilityType ]
  )
  res.redirect('/facilities')
})

app.get('/facilities/:id/edit', async (req, res, next) => {
  try {
    const [[facility]] = await pool.query(
      `SELECT facilityID,name,location,facilityType
         FROM disposalFacilities
        WHERE facilityID=?`,
      [ req.params.id ]
    )
    res.render('facilities-edit', {
      title:'Edit Facility',
      facilityID: facility.facilityID,
      name:       facility.name,
      location:   facility.location,
      facilityType: facility.facilityType
    })
  } catch (e) { next(e) }
})


app.post('/facilities/:id/edit', async (req, res) => {
  const { name, location, facilityType } = req.body
  await pool.query(
    `UPDATE disposalFacilities
        SET name=?, location=?, facilityType=?
      WHERE facilityID=?`,
    [ name, location, facilityType, req.params.id ]
  )
  res.redirect('/facilities')
})

app.get('/facilities/:id/delete', async (req, res, next) => {
  try {
    const [[facility]] = await pool.query(
      `SELECT facilityID,name
         FROM disposalFacilities
        WHERE facilityID=?`,
      [ req.params.id ]
    )
    res.render('facilities-delete', {
      title:'Delete Facility',
      facilityID: facility.facilityID,
      name:       facility.name
    })
  } catch (e) { next(e) }
})

app.post('/facilities/:id/delete', async (req, res) => {
  await pool.query(
    `DELETE FROM disposalFacilities WHERE facilityID=?`,
    [ req.params.id ]
  )
  res.redirect('/facilities')
})


//ROUTES


app.get('/routes', async (req, res, next) => {
  try {
    const [routes] = await pool.query(`
      SELECT routeID, name, routeType, schedule, activeRoute, vehicleID
        FROM routes
    `);
    res.render('routes-list', { title: 'Routes', routes });
  } catch (err) {
    next(err);
  }
});

app.get('/routes/new', (req, res) => {
  res.render('routes-new', { title: 'New Route' });
});

app.post('/routes/new', async (req, res, next) => {
  try {
    const { name, routeType, schedule, activeRoute, vehicleID } = req.body;
    await pool.query(
      `INSERT INTO routes (name, routeType, schedule, activeRoute, vehicleID)
       VALUES (?, ?, ?, ?, ?)`,
      [name, routeType, schedule, activeRoute ? 1 : 0, vehicleID || null]
    );
    res.redirect('/routes');
  } catch (err) {
    next(err);
  }
});

app.get('/routes/:id/edit', async (req, res, next) => {
  try {
    const [[route]] = await pool.query(
      `SELECT routeID, name, routeType, schedule, activeRoute, vehicleID
         FROM routes
        WHERE routeID = ?`,
      [req.params.id]
    );
    res.render('routes-edit', {
      title: 'Edit Route',
      routeID:      route.routeID,
      name:          route.name,
      routeType:    route.routeType,
      schedule:      route.schedule,
      activeRoute:  route.activeRoute,
      vehicleID:    route.vehicleID
    });
  } catch (err) {
    next(err);
  }
});


app.post('/routes/:id/edit', async (req, res, next) => {
  try {
    const { name, routeType, schedule, activeRoute, vehicleID } = req.body;
    await pool.query(
      `UPDATE routes
          SET name = ?, routeType = ?, schedule = ?, activeRoute = ?, vehicleID = ?
        WHERE routeID = ?`,
      [name, routeType, schedule, activeRoute ? 1 : 0, vehicleID || null, req.params.id]
    );
    res.redirect('/routes');
  } catch (err) {
    next(err);
  }
});

app.get('/routes/:id/delete', async (req, res, next) => {
  try {
    const [[route]] = await pool.query(
      `SELECT routeID, name FROM routes WHERE routeID = ?`,
      [req.params.id]
    );
    res.render('routes-delete', {
      title: 'Delete Route',
      routeID: route.routeID,
      name:     route.name
    });
  } catch (err) {
    next(err);
  }
});


app.post('/routes/:id/delete', async (req, res, next) => {
  try {
    await pool.query(
      `DELETE FROM routes WHERE routeID = ?`,
      [req.params.id]
    );
    res.redirect('/routes');
  } catch (err) {
    next(err);
  }
});


//VEHICLES

app.get('/vehicles', async (req, res, next) => {
  try {
    const [vehicles] = await pool.query(`
      SELECT vehicleID, licensePlate, serviceType, status, wasteTypeID
        FROM vehicles
    `);
    res.render('vehicles-list', { title: 'Vehicles', vehicles });
  } catch (err) {
    next(err);
  }
});


app.get('/waste-types', async (req, res, next) => {
  try {
    const [wasteTypes] = await pool.query(`
      SELECT wasteTypeID, material, hazardous
        FROM wasteTypes
    `);
    res.render('waste-types-list', { title: 'Waste Types', wasteTypes });
  } catch (err) {
    next(err);
  }
});

app.get('/facility-waste-types', async (req, res, next) => {
  try {
    const [links] = await pool.query(`
      SELECT 
        dfht.facilityWasteTypeID,
        df.name AS facilityName,
        wt.material AS wasteTypeMaterial
      FROM disposalFacilitiesHasWasteTypes dfht
      JOIN disposalFacilities df ON dfht.facilityID = df.facilityID
      JOIN wasteTypes wt ON dfht.wasteTypeID = wt.wasteTypeID
    `);
    res.render('facility-waste-types-list', {
      title: 'Facility Waste Types',
      links
    });
  } catch (err) {
    next(err);
  }
});

const PORT = process.env.PORT || 6917;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});