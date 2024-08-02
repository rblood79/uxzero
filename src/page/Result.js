import _ from 'lodash';
import 'remixicon/fonts/remixicon.css'
import React, { useState, useEffect, useContext, useRef, useCallback, useMemo } from 'react';
import context from '../component/Context';
import { useHistory } from "react-router-dom";
import { isMobile } from 'react-device-detect';
import { doc, query, where, getDoc, getDocs, orderBy, deleteDoc } from 'firebase/firestore';
import moment from "moment";

const App = (props) => {
  const history = useHistory();
  const state = useContext(context);
  //const location = useLocation();
  const { user } = state;
  const [data, setData] = useState([]);
  const [result, setResult] = useState([]);
  const tableRef = useRef();

  const style = {
    table: {
      width: "100%",
      height: "1px",
      borderCollapse: "collapse",
      border: "2px solid #000",
      backgroundColor: "#fff",
      fontSize: "12px",
      tableLayout: "fixed",
      th: {
        background: "#efefef",
        border: isMobile ? "1px solid #d3d3d3" : "0.5pt solid #d3d3d3",
        fontWeight: "400",
        padding: "6px 4px",
        height: "51px",
        minHeight: "51px",
        wordBreak: "keep-all",
        borderBottom: isMobile ? "1px solid #ccc" : "0.5pt solid #ccc"
      },
      thE: {
        width: isMobile ? "0pt" : "0.5pt",
      },
      tdE: {
        height: "51px",
        minHeight: "51px",
      },
      td: {
        border: isMobile ? "1px solid #d3d3d3" : "0.5pt solid #d3d3d3",
        fontWeight: "400",
        padding: "6px 4px",
        height: "51px",
        minHeight: "51px",
        wordBreak: "keep-all",
        textAlign: "center",
      },
      tdB: {
        border: isMobile ? "1px solid #d3d3d3" : "0.5pt solid #d3d3d3",
        fontWeight: "400",
        padding: "6px 4px",
        height: "51px",
        minHeight: "51px",
        wordBreak: "break-all",
        textAlign: "center",
      },
      tdRed: {
        background: "#D01414",
      },
      tdGreen: {
        background: "#20D067",
      },
      tdYellow: {
        background: "#EFD214",
      },
      tdNormal: {
        background: "#efefef",
      }
    }
  };

  const ItemList = (props) => {
    const item = props.data;
    const indiArray = item.INDI ? item.INDI.split('\n') : [];
    const unitArray = item.UNIT ? item.UNIT.split('\n') : [];
    const d0Array = item.DATAY0 ? item.DATAY0.split('\n') : [];
    const d1Array = item.DATAY1 ? item.DATAY1.split('\n') : [];
    const d2Array = item.DATAY2 ? item.DATAY2.split('\n') : [];
    const d3Array = item.DATAY3 ? item.DATAY3.split('\n') : [];
    const d4Array = item.DATAY4 ? item.DATAY4.split('\n') : [];
    const d5Array = item.DATAY5 ? item.DATAY5.split('\n') : [];

    const rspan = indiArray.length > 0 ? indiArray.length : 1;
    return (
      <>
        <tr onDoubleClick={() => !isMobile && test(item)}>
          <td rowSpan={rspan} style={style.table.td}>{item.ID}</td>
          <td rowSpan={rspan} style={style.table.tdB}>{item.CHECKNUM}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.LEADER}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.TITLE}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.STARTCOMPYEAR}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.STARTCOMPRESULT}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.ENDCOMPYEAR}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.ENDCOMPRESULT}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.STARTYEAR}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.STARTRESULT}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.ENDCOMPYEAR}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.ENDRESULT}</td>
          <td rowSpan={rspan} style={style.table.td}>{item.RESULT}</td>
          <td rowSpan={rspan} style={item.COLOR === 'red' ? style.table.tdRed : item.COLOR === 'green' ? style.table.tdGreen : item.COLOR === 'yellow' ? style.table.tdYellow : style.table.tdNormal}></td>
          <td style={style.table.td}>{indiArray[0]}</td>
          <td style={style.table.td}>{unitArray[0]}</td>
          <td style={style.table.td}>{d0Array[0]}</td>
          <td style={style.table.td}>{d1Array[0]}</td>
          <td style={style.table.td}>{d2Array[0]}</td>
          <td style={style.table.td}>{d3Array[0]}</td>
          <td style={style.table.td}>{d4Array[0]}</td>
          <td style={style.table.td}>{d5Array[0]}</td>
          {isMobile ? <td className='delTd' onClick={() => { test(item) }}><i className="ri-edit-circle-fill"></i></td> : <td className='delTd' onClick={() => { onDelete(item.ID) }}><i className="ri-close-circle-fill"></i></td>}
        </tr>
        {indiArray.slice(1).map((indi, index) => (
          <tr key={`list${index + 1}`} onDoubleClick={() => !isMobile && test(item)}>
            <td style={style.table.td}>{indi}</td>
            <td style={style.table.td}>{unitArray[index + 1]}</td>
            <td style={style.table.td}>{d0Array[index + 1]}</td>
            <td style={style.table.td}>{d1Array[index + 1]}</td>
            <td style={style.table.td}>{d2Array[index + 1]}</td>
            <td style={style.table.td}>{d3Array[index + 1]}</td>
            <td style={style.table.td}>{d4Array[index + 1]}</td>
            <td style={style.table.td}>{d5Array[index + 1]}</td>
          </tr>
        ))}
      </>
    );
  };

  const test = (e) => {
    history.push({
      pathname: '/form',
      state: { userCell: e.ID }
    });
  };

  const onDelete = async (id) => {
    await deleteDoc(doc(props.manage, id));
    onCheck(id);
  };

  const onCheck = async (id) => {
    const docRef = doc(props.manage, id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      console.log('Document still exists!');
    } else {
      //console.log('Document deleted');
      onLoad();
    }
  };

  /*const onReset = () => {
    setInputs({
      regNum: '', regTitle: '', regLeader: '', regIndi: ''
    })
    setColor('all');
    setResult(data);
  }*/
  const onLoad = useCallback(async () => {
    //console.log('onload--------------')
    const manageDoc = [];
    const q = query(props.manage, where("ID", "!=", ""), orderBy("ID", "desc"));
    const querySnapshot = await getDocs(q);
    querySnapshot.forEach((doc) => {
      manageDoc.push({ id: doc.id, ...doc.data() });
    });
    setData(manageDoc);
  }, [props.manage]);

  useEffect(() => {
    //console.log('data change', data)
    data && handleSearch();
  // eslint-disable-next-line no-use-before-define
  }, [data, handleSearch])

  const onDownload = async () => {
    let xData = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
    xData += '<head><meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">';
    xData += '<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>'
    xData += '<x:Name>DATA Sheet</x:Name>';
    xData += '<x:WorksheetOptions><x:Panes></x:Panes></x:WorksheetOptions></x:ExcelWorksheet>';
    xData += '</x:ExcelWorksheets></x:ExcelWorkbook></xml>';
    xData += '</head><body>';
    xData += tableRef.current.outerHTML;
    xData += '</body></html>';

    let fileName = moment(new Date()).format("YYYYMMDD");
    let blob = new Blob([xData], {
      type: "application/csv;charset=utf-8;"
    });
    let a = document.createElement("a");
    a.href = window.URL.createObjectURL(blob);
    a.download = "과제관리" + fileName + ".xls";
    a.click();
  };

  useEffect(() => {
    if (!user) {
      history.push('/');
    } else {
      //onLoad();
      const timer = setTimeout(() => {
        onLoad();
      }, 100);
      return () => clearTimeout(timer);	// 타이머 클리어
    }
  }, [user, history, onLoad]);

  /*useEffect(() => {
    if (location.state && location.state.updated) {
      onLoad();
      history.replace({ state: {} });
    }
  }, [history, location, onLoad]);*/

  const [inputs, setInputs] = useState({
    regNum: "",
    regTitle: "",
    regLeader: "",
    regIndi: "",
  });
  const { regNum, regTitle, regLeader, regIndi } = inputs;
  const [regColor, setColor] = useState('all');

  const onChange = (e) => {
    const { name, value } = e.target;
    setInputs({
      ...inputs,
      [name]: value || "",
    });
  };

  const memoizedResult = useMemo(() => {
    return _.filter(data, function (o) {
      const isNumMatch = !regNum || o.ID.includes(regNum);
      const isTitleMatch = !regTitle || o.TITLE.includes(regTitle);
      const isIndiMatch = !regIndi || o.INDI.includes(regIndi);
      const isLeaderMatch = !regLeader || o.LEADER.includes(regLeader);
      const isColorMatch = regColor === 'all' || o.COLOR === regColor;

      return isNumMatch && isTitleMatch && isLeaderMatch && isColorMatch && isIndiMatch;
    });
  }, [data, regNum, regTitle, regLeader, regColor, regIndi]);

  const handleSearch = useCallback(() => {
    setResult(memoizedResult);
    //console.log('handleSearch end')
  }, [memoizedResult]);

  return (
    <div className='resultContainer'>
      <div className='users'>
        <div className='resultHead'>
          <h2 className='title'>과제현황<span className='titleSub'>- 전체 {data.length} 중 {result.length}건</span></h2>
          <div className='resultRight'>
          </div>
        </div>
        <div>
          <div className='searchForm'>
            <div className='formWrap'>
              <label className='label'>관리번호</label>
              <input
                name="regNum"
                placeholder="관리번호"
                onChange={onChange}
                value={regNum}
              />
            </div>
            <div className='formWrap'>
              <label className='label'>과제명</label>
              <input
                name="regTitle"
                placeholder="과제명"
                onChange={onChange}
                value={regTitle}
              />
            </div>
            <div className='formWrap'>
              <label className='label'>팀장</label>
              <input
                name="regLeader"
                placeholder="팀장"
                onChange={onChange}
                value={regLeader}
              />
            </div>
            <div className='formWrap'>
              <label className='label'>관리지표</label>
              <input
                name="regIndi"
                placeholder="관리지표"
                onChange={onChange}
                value={regIndi}
              />
            </div>
            <div className='formWrap'>
              <label className='label'>사후관리</label>
              <select onChange={(e) => { setColor(e.target.value) }} value={regColor}>
                <option value="all">전체</option>
                <option value="red">red</option>
                <option value="green">green</option>
                <option value="yellow">yellow</option>
              </select>
            </div>
            <button className="search" onClick={handleSearch}><i className="ri-search-line"></i></button>
            {/*<button className="refresh" onClick={onReset}><i className="ri-refresh-line"></i></button>*/}
            {!isMobile && <button className="search excel" onClick={onDownload}><i className="ri-file-excel-2-line"></i></button>}
          </div>
          <div className='tableContents'>
            <table ref={tableRef} style={style.table}>
              <colgroup>
                <col width="70px" />
                <col width="110px" />
                <col width="50px" />
                <col width="150px" />
                <col width="60px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="80px" />
                <col width="40px" />
                <col width={isMobile ? "234px" : "auto"} />
                <col width="48px" />
                <col width="84px" />
                <col width="84px" />
                <col width="84px" />
                <col width="84px" />
                <col width="84px" />
                <col width="84px" />
                <col width="0px" />
              </colgroup>
              <thead>
                <tr>
                  <th style={style.table.th}>관리번호</th>
                  <th style={style.table.th}>확인번호</th>
                  <th style={style.table.th}>팀장</th>
                  <th style={style.table.th}>과제명</th>
                  <th style={style.table.th}>1차완료<br />평가연도</th>
                  <th style={style.table.th}>1차완료<br />평가결과</th>
                  <th style={style.table.th}>2차완료<br />평가연도</th>
                  <th style={style.table.th}>2차완료<br />평가결과</th>
                  <th style={style.table.th}>1차성과<br />평가연도</th>
                  <th style={style.table.th}>1차성과<br />평가결과</th>
                  <th style={style.table.th}>2차성과<br />평가연도</th>
                  <th style={style.table.th}>2차성과<br />평가결과</th>
                  <th style={style.table.th}>재무성과<br />(원)</th>
                  <th style={style.table.th}>사후<br />관리</th>
                  <th style={style.table.th}>관리지표</th>
                  <th style={style.table.th}>단위</th>
                  <th style={style.table.th}>수치</th>
                  <th style={style.table.th}>Y+1</th>
                  <th style={style.table.th}>Y+2</th>
                  <th style={style.table.th}>Y+3</th>
                  <th style={style.table.th}>Y+4</th>
                  <th style={style.table.th}>Y+5</th>
                  <th style={style.table.thE}></th>
                </tr>
              </thead>
              <tbody>
                {
                result.length > 0 ? result.map((item) => (
                  <ItemList key={item.ID + item.DATE} data={item} />
                )) : <tr><td colSpan="22" style={style.table.tdE}>데이터가 없습니다</td></tr>
                }
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}

App.defaultProps = {};

export default App;
