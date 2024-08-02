
import './App.css';
import { isMobile } from 'react-device-detect';
import { Route,} from "react-router-dom";

import React, { useContext, useEffect } from 'react';
import context from './component/Context';

import Head from './component/Head';
import Foot from './component/Foot';

import Home from './page/Home';
import Form from './page/Form';
import Result from './page/Result';

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getFirestore, collection } from 'firebase/firestore';
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyD4lFYlGsKryHvQUF5CT3wUdhnU_uQBVUA",
  authDomain: "army-c3fb4.firebaseapp.com",
  projectId: "army-c3fb4",
  storageBucket: "army-c3fb4.appspot.com",
  messagingSenderId: "806478232160",
  appId: "1:806478232160:web:893774803a8773caa12105",
  measurementId: "G-SX7YFMRCJZ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const manageRef = collection(db, "manage");

const App = (props) => {
  const state = useContext(context);
  const { user } = state;

  useEffect(() => {
    //console.log(props.location.pathname)
  }, [])
  return (
    <div className={isMobile ? "App mobile" : "App"} style={{ height: props.location.pathname === '/' && '100%', backgroundColor:  props.location.pathname === '/main' && '#0078D7'}}>
      {user && <Head path={props.location.pathname}/>}
      <main className='main'>
        <Route exact path="/" render={() => <Home manage={manageRef}/>} />
        <Route path="/form" render={() => <Form manage={manageRef}/>} />
        <Route path="/result" render={() => <Result manage={manageRef}/>} />
      </main>
      <Foot />
    </div>
  );
}

/*function App() {
  return (
    <div className="App">
      <header className="App-header">
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}*/

export default App;
