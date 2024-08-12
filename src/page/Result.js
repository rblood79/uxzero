
import _ from 'lodash';
import 'remixicon/fonts/remixicon.css'
import React, { useState, useEffect, useContext, useRef, useCallback, useMemo } from 'react';
import context from '../component/Context';
import { useHistory } from "react-router-dom";
import { isMobile } from 'react-device-detect';
import { query, where, orderBy, onSnapshot } from 'firebase/firestore';
import moment from "moment";


const App = (props) => {
  const history = useHistory();
  const state = useContext(context);
  //const location = useLocation();
  const { user } = state;
  const [data, setData] = useState([]);
  const [result, setResult] = useState([]);
  const [startYear, setStartYear] = useState('all');
  const [endYear, setEndYear] = useState('all');

  const [startcompresult, setStartcompresult] = useState('all');
  const [endcompresult, setEndcompresult] = useState('all');

  const [startResult, setStartResult] = useState('all');
  const [endResult, setEndResult] = useState('all');

  const [startResult2, setStartResult2] = useState('all');
  const [endResult2, setEndResult2] = useState('all');

  const tableRef = useRef();

  const yearArray = ["2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030", "2031", "2032", "2033", "2034"];
  const startCompResultArray = ["완료", "조건부완료", "중단", "연장", "미평가"];
  const endCompResultArray = ["완료", "조건부완료", "중단", "연장", "1차완료", "미평가"];

  const startResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "미인증(재도전)"];
  const endResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "1차인증"];


  const style = {
    table: {
      width: "100%",
      height: "1px",
      borderCollapse: "collapse",
      border: "2px solid #000",
      backgroundColor: "#fff",
      fontSize: "12px",
      tableLayout: "fixed",
      caption: {
        fontSize: "21px",
        fontWeight: "600",
        padding: "16px",
        textAlign: "center",
        height: "96px",
      },
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
        borderBottom: isMobile ? "1px solid rgba(0,0,0,0.3)" : "0.5pt solid rgba(0,0,0,0.3)",
      },
      tdGreen: {
        background: "#20D067",
        borderBottom: isMobile ? "1px solid rgba(0,0,0,0.3)" : "0.5pt solid rgba(0,0,0,0.3)",
      },
      tdYellow: {
        background: "#EFD214",
        borderBottom: isMobile ? "1px solid rgba(0,0,0,0.3)" : "0.5pt solid rgba(0,0,0,0.3)",
      },
      tdNormal: {
        background: "#efefef",
        borderBottom: isMobile ? "1px solid rgba(0,0,0,0.3)" : "0.5pt solid rgba(0,0,0,0.3)",
      }
    }
  };

  const ItemList = (props) => {
    const item = props.data;
    const indiArray = item.INDI ? item.INDI.split('\n').slice(0, 10) : [];
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
          <td rowSpan={rspan} style={style.table.td}>{item.ENDYEAR}</td>
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
          <td className='delTd' onClick={() => { onView(item) }}><i className="ri-arrow-right-circle-fill"></i></td>
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

  const onView = (e) => {
    history.push({
      pathname: '/view',
      state: { userCell: e.ID }
    });
  };

  /*const onDelete = async (id) => {
    await deleteDoc(doc(props.manage, id));
    onCheck(id);
  };

  const onCheck = async (id) => {
    const docRef = doc(props.manage, id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      console.log('Document still exists!');
    } else {
      onLoad();
    }
  };*/

  /*const onReset = () => {
    setInputs({
      regNum: '', regTitle: '', regLeader: '', regIndi: ''
    })
    setColor('all');
    setResult(data);
  }*/


  useEffect(() => {
    data && handleSearch();
    // eslint-disable-next-line no-use-before-define
  }, [data, handleSearch])

  const onDownload = async () => {
    let xData = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
    xData += '<head><meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">';
    xData += '<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>'
    xData += '<x:Name>과제관리대장</x:Name>';
    xData += '<x:WorksheetOptions><x:Panes></x:Panes></x:WorksheetOptions></x:ExcelWorksheet>';
    xData += '</x:ExcelWorksheets></x:ExcelWorkbook></xml>';
    xData += '<style></style>';
    xData += '</head><body>';
    xData += tableRef.current.outerHTML;
    xData += '</body></html>';

    let fileName = moment(new Date()).format("YYYYMMDD");
    let blob = new Blob([xData], {
      type: "application/vnd.ms-excel;charset=utf-8;"
    });
    let a = document.createElement("a");
    a.href = window.URL.createObjectURL(blob);
    a.download = "과제관리" + fileName + ".xls";
    a.click();
  };

  const onLoad = useCallback(async () => {
    const q = query(props.manage, where("ID", "!=", ""), orderBy("ID", "desc"));
    const unsubscribe = onSnapshot(q, (querySnapshot) => {
      const manageDoc = [];
      querySnapshot.forEach((doc) => {
        manageDoc.push({ ...doc.data(), id: doc.id });
      });
      setData(manageDoc);
    });

    // 컴포넌트 언마운트 시 리스너 해제
    return () => unsubscribe();
  }, [props.manage]);


  useEffect(() => {
    if (!user) {
      history.push('/');
    } else {
      const unsubscribe = onLoad();
      if (typeof unsubscribe === 'function') {
        return () => unsubscribe();  // Clean up on unmount
      }
    }
  }, [history, onLoad, user]);


  const [inputs, setInputs] = useState({
    regNum: "",
    regTitle: "",
    regLeader: "",
    regEndCompYear: "",
    regEndYear: "",
  });
  const { regNum, regTitle, regLeader, regEndCompYear, regEndYear } = inputs;
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
      const isEndCompYearMatch = !regEndCompYear || o.ENDCOMPYEAR.includes(regEndCompYear);
      const isLeaderMatch = !regLeader || o.LEADER.includes(regLeader);
      const isColorMatch = regColor === 'all' || o.COLOR === regColor;
      const isDateMatch = (startYear === 'all' || (o.STARTCOMPYEAR >= startYear && o.STARTCOMPYEAR <= endYear)) && (endYear === 'all' || (o.STARTCOMPYEAR <= endYear));
      const isStartCompResultMatch = startcompresult === 'all' || o.STARTCOMPRESULT === startcompresult;
      const isEndCompResultMatch = endcompresult === 'all' || o.ENDCOMPRESULT === endcompresult;
      const isDateMatch2 = (startResult === 'all' || (o.STARTYEAR >= startResult && o.STARTYEAR <= endResult)) && (endResult === 'all' || (o.STARTYEAR <= endResult));

      const isStartResultMatch = startResult2 === 'all' || o.STARTRESULT === startResult2;
      const isEndYearMatch = !regEndYear || o.ENDYEAR.includes(regEndYear);

      const isEndResultMatch = endResult2 === 'all' || o.ENDRESULT === endResult2;

      return isNumMatch && isTitleMatch && isLeaderMatch && isColorMatch && isEndCompYearMatch && isDateMatch && isStartCompResultMatch && isEndCompResultMatch && isDateMatch2 && isStartResultMatch && isEndYearMatch && isEndResultMatch;
    });
  }, [data, regNum, regTitle, regEndCompYear, regLeader, regColor, startYear, endYear, startcompresult, endcompresult, startResult, endResult, startResult2, regEndYear, endResult2]);

  const handleSearch = useCallback(() => {
    setResult(memoizedResult);
  }, [memoizedResult]);

  const onPrint = () => {
    const style = document.createElement('style');
    //style.type = 'text/css';
    style.media = 'print';
    style.innerHTML = `
        body{
          background: #fff;
          padding: 0mm !important;
        }
        table {
          font-size: 10px !important;
          table-layout: auto !important;
          border: 0 !important;
        }
        th, td {
          border-color: #333 !important;
        }
        @page {
            size: landscape A3 !important;
            margin: 10mm !important;
        }
    `;
    // head 태그에 스타일을 추가합니다.
    document.head.appendChild(style);
    window.print();
    // 인쇄 후 스타일 시트를 제거합니다.
    document.head.removeChild(style);
  }

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
            <div className='searchGroup'>
              <div className='formWrap'>
                <label className='label' >팀장</label>
                <input
                  name="regLeader"
                  placeholder=""
                  onChange={onChange}
                  value={regLeader}
                />
              </div>
              <div className='formWrap span2'>
                <label className='label'>과제명</label>
                <input
                  name="regTitle"
                  placeholder=""
                  onChange={onChange}
                  value={regTitle}
                />
              </div>
              <div className='formWrap'>
                <label className='label'>1차 완료평가연도</label>
                <select onChange={(e) => { setStartYear(e.target.value) }} value={startYear}>
                  <option value="all">전체</option>
                  {yearArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
                <span className='space'>~</span>
                <select onChange={(e) => { setEndYear(e.target.value) }} value={endYear}>
                  <option value="all">전체</option>
                  {yearArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap'>
                <label className='label'>1차 완료평가결과</label>
                <select onChange={(e) => { setStartcompresult(e.target.value) }} value={startcompresult}>
                  <option value="all">전체</option>
                  {startCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>2차 완료평가연도</label>
                <input
                  name="regEndCompYear"
                  placeholder=""
                  onChange={onChange}
                  value={regEndCompYear}
                />
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>2차 완료평가결과</label>
                <select onChange={(e) => { setEndcompresult(e.target.value) }} value={endcompresult}>
                  <option value="all">전체</option>
                  {endCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>1차 성과평가연도</label>
                <select onChange={(e) => { setStartResult(e.target.value) }} value={startResult}>
                  <option value="all">전체</option>
                  {yearArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
                <span className='space'>~</span>
                <select onChange={(e) => { setEndResult(e.target.value) }} value={endResult}>
                  <option value="all">전체</option>
                  {yearArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>1차 성과평가결과</label>
                <select onChange={(e) => { setStartResult2(e.target.value) }} value={startResult2}>
                  <option value="all">전체</option>
                  {startResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>2차 성과평가연도</label>
                <input
                  name="regEndYear"
                  placeholder=""
                  onChange={onChange}
                  value={regEndYear}
                />
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>2차 성과평가결과</label>
                <select onChange={(e) => { setEndResult2(e.target.value) }} value={endResult2}>
                  <option value="all">전체</option>
                  {endResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label'>사후관리상태</label>
                <select onChange={(e) => { setColor(e.target.value) }} value={regColor}>
                  <option value="all">전체</option>
                  <option value="red">red</option>
                  <option value="green">green</option>
                  <option value="yellow">yellow</option>
                </select>
              </div>

            </div>
          </div>
          <div className='controll'>
            <button className="button search" onClick={handleSearch}>검색</button>
            {/*<button className="refresh" onClick={onReset}><i className="ri-refresh-line"></i></button>*/}
            {
              !isMobile &&
              <>
                <button className="button excel" onClick={onDownload}>엑셀다운</button>
                <button className="button print" onClick={onPrint}>인쇄</button>
              </>
            }
          </div>
          <div className='tableContents'>
            <table ref={tableRef} style={style.table}>
              <colgroup>
                <col width="70px" />
                <col width="110px" />
                <col width="50px" />
                <col width="340px" />
                <col width="54px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="54px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="70px" />
                <col width="54px" />
                <col width={isMobile ? "170px" : "auto"} />
                <col width="48px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="0px" />
              </colgroup>
              <thead>
                <tr>
                  <td colSpan="22" style={style.table.caption} className='caption'>과제관리대장</td>
                </tr>
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
                  <th style={style.table.th}>사후<br />관리상태</th>
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
                  )) : <tr><td colSpan="22" style={style.table.tdE}>자료가 없습니다</td></tr>
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
