
import './App.css';
import { isMobile } from 'react-device-detect';
import { Route } from "react-router-dom";

import React, { useContext, useEffect } from 'react';
import context from './component/Context';

import Head from './component/Head';
import Foot from './component/Foot';

import Sign from './page/Sign';
import Write from './page/Write';
import List from './page/List';
import View from './page/View';

// Import the functions you need from the SDKs you need
//import { initializeApp } from "firebase/app";
import firebase from './firebase';
import { getFirestore, collection } from 'firebase/firestore';
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Initialize Firebase
//const app = initializeApp(firebaseConfig);
const app = firebase;
const db = getFirestore(app);
const manageRef = collection(db, "manage");

const App = (props) => {
  const state = useContext(context);
  const { user } = state;
  const appClass = isMobile ? "App mobile" : "App";

  useEffect(() => {
    //console.log(props.location.pathname)
  }, [])
  return (
    <div className={appClass}>
      {
        !user ?
          <Route path="/" render={() => <Sign manage={manageRef} />} /> :
          <>
            <Head path={props.location.pathname} />
            <main className='main'>
              <Route exact path="/" render={() => <List manage={manageRef} />} />
              <Route path="/write" render={() => <Write manage={manageRef}/>} />
              <Route path="/view" render={() => <View manage={manageRef}/>} />
            </main>
          </>
      }
      <Foot />
    </div>
  );
}

export default App;
