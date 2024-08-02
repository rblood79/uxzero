


const App = (props) => {
    return (
      <footer className={props.position === 'fix' ? "foot active" : "foot"}>
         ministry of national defense.
      </footer>
    );
  }
  
  App.defaultProps = {
    topNum: null,
    type: 'list',
  };
  
  export default App;