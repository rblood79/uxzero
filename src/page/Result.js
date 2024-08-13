
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
  const { user, year } = state;
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

  const tableRef = useRef(null);


  const startCompResultArray = ["완료", "조건부완료", "중단", "연장", "미평가"];
  const endCompResultArray = ["완료", "조건부완료", "중단", "연장", "1차완료", "미평가"];

  const startResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "미인증(재도전)"];
  const endResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "1차인증"];

  const [minYear] = useState(year[0]);
  const [maxYear] = useState(year[1]);

  /*const getYearRange = (startYear, endYear) => {
    const yearArray = [];
    for (let year = startYear; year <= endYear; year++) {
      yearArray.push(year.toString());
    }
    return yearArray;
  };*/

  const useYearRange = (startYear, endYear) => {
    const getYearRange = useCallback(() => {
      const yearArray = [];
      for (let year = startYear; year <= endYear; year++) {
        yearArray.push(year.toString());
      }
      return yearArray;
    }, [startYear, endYear]);
    // useMemo로 getYearRange의 결과를 메모이제이션
    const years = useMemo(() => getYearRange(), [getYearRange]);

    return years;
  };

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
          <td className='editTd' onClick={() => { test(item) }}><i className="ri-edit-fill"></i></td>
          <td className='detailTd' onClick={() => { onView(item) }}><i className="ri-printer-fill"></i></td>
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
            <td style={style.table.td} className='printHide'></td>
            <td style={style.table.td} className='printHide'></td>
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

  /*const onDownload = async () => {
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

    const fileName = moment(new Date()).format("YYYYMMDD");
    const blob = new Blob([xData], {
      type: "application/vnd.ms-excel;charset=utf-8;"
    });
    const a = document.createElement("a");
    a.href = window.URL.createObjectURL(blob);
    a.download = "과제관리" + fileName + ".xls";
    a.click();

    xData = null;
  };*/
  const onDownload = useCallback(() => {
    // 1. 테이블의 깊은 복사본 생성
    const table = tableRef.current.cloneNode(true);

    // 2. 복사본에서 불필요한 요소 제거
    // <colgroup> 내의 마지막 두 개의 <col> 요소 삭제
    const colgroup = table.querySelector('colgroup');
    const cols = colgroup.querySelectorAll('col');
    cols[cols.length - 2].remove();
    cols[cols.length - 1].remove();

    // `printHide`, `editTd`, `detailTd` 클래스의 요소 제거
    table.querySelectorAll('.printHide').forEach(el => el.remove());
    table.querySelectorAll('.editTd').forEach(el => el.remove());
    table.querySelectorAll('.detailTd').forEach(el => el.remove());

    // 3. 엑셀 데이터 생성
    let xData = `
        <html xmlns:x="urn:schemas-microsoft-com:office:excel">
            <head>
                <meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">
                <xml>
                    <x:ExcelWorkbook>
                        <x:ExcelWorksheets>
                            <x:ExcelWorksheet>
                                <x:Name>과제관리대장</x:Name>
                                <x:WorksheetOptions>
                                    <x:Panes></x:Panes>
                                </x:WorksheetOptions>
                            </x:ExcelWorksheet>
                        </x:ExcelWorksheets>
                    </x:ExcelWorkbook>
                </xml>
            </head>
            <body>${table.outerHTML}</body>
        </html>
    `;

    // 4. Blob을 이용해 엑셀 파일 다운로드
    const fileName = moment(new Date()).format("YYYYMMDD");
    const blob = new Blob([xData], { type: "application/vnd.ms-excel;charset=utf-8;" });
    const a = document.createElement("a");
    a.href = window.URL.createObjectURL(blob);
    a.download = "과제관리" + fileName + ".xls";
    a.click();

    // 복구 작업 필요 없음

  }, [tableRef]);

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
    // <colgroup> 내의 마지막 두 개의 <col> 요소를 선택합니다.
    const table = tableRef.current;
    const colgroup = table.querySelector('colgroup');
    const cols = colgroup.querySelectorAll('col');
    // 마지막 두 개의 <col> 요소의 원래 width를 저장해 둡니다.
    const originalWidths = [cols[cols.length - 2].getAttribute('width'), cols[cols.length - 1].getAttribute('width')];

    // 마지막 두 개의 <col> 요소의 width를 0px로 변경합니다.
    cols[cols.length - 2].setAttribute('width', '0px');
    cols[cols.length - 1].setAttribute('width', '0px');

    const style = document.createElement('style');
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
            size: A3 landscape !important;
            margin: 10mm !important;
        }
    `;
    // head 태그에 스타일을 추가합니다.
    document.head.appendChild(style);
    window.print();
    // 인쇄 후 스타일 시트를 제거합니다.
    document.head.removeChild(style);
    cols[cols.length - 2].setAttribute('width', originalWidths[0]);
    cols[cols.length - 1].setAttribute('width', originalWidths[1]);
  }

  return (
    <div className='resultContainer'>
      <div className='users'>
        <div className='resultHead'>
          <h2 className='title'>과제등록현황<span className='titleSub'>- 전체 {data.length} 중 {result.length}건</span></h2>
          <div className='resultRight'>
          </div>
        </div>

        <div>
          <div className='searchForm'>
            <div className='searchGroup'>
              <div className='formWrap'>
                <label className='label' htmlFor='RL'>팀장</label>
                <input
                  id="RL"
                  name="regLeader"
                  placeholder=""
                  onChange={onChange}
                  value={regLeader}
                />
              </div>
              <div className='formWrap span2'>
                <label className='label' htmlFor='RT'>과제명</label>
                <input
                  id='RT'
                  name="regTitle"
                  placeholder=""
                  onChange={onChange}
                  value={regTitle}
                />
              </div>
              <div className='formWrap'>
                <label className='label' htmlFor='SY'>1차 완료평가연도</label>
                <select id="SY" onChange={(e) => { setStartYear(e.target.value) }} value={startYear}>
                  <option value="all">전체</option>
                  {
                    useYearRange(minYear, maxYear).map((item) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))
                  }
                </select>
                <span className='space'>~</span>
                <select id="EY" onChange={(e) => { setEndYear(e.target.value) }} value={endYear}>
                  <option value="all">전체</option>
                  {
                    useYearRange(startYear, maxYear).map((item) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))
                  }
                </select>
              </div>

              <div className='formWrap'>
                <label className='label' htmlFor='SCR'>1차 완료평가결과</label>
                <select id="SCR" onChange={(e) => { setStartcompresult(e.target.value) }} value={startcompresult}>
                  <option value="all">전체</option>
                  {startCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='RECY'>2차 완료평가연도</label>
                <input
                  id='RECY'
                  name="regEndCompYear"
                  placeholder=""
                  onChange={onChange}
                  value={regEndCompYear}
                />
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='ECR'>2차 완료평가결과</label>
                <select id="ECR" onChange={(e) => { setEndcompresult(e.target.value) }} value={endcompresult}>
                  <option value="all">전체</option>
                  {endCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='SR'>1차 성과평가연도</label>
                <select id="SR" onChange={(e) => { setStartResult(e.target.value) }} value={startResult}>
                  <option value="all">전체</option>
                  {
                    useYearRange(2020, 2030).map((item) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))
                  }
                </select>
                <span className='space'>~</span>
                <select id="ER" onChange={(e) => { setEndResult(e.target.value) }} value={endResult}>
                  <option value="all">전체</option>
                  {
                    useYearRange(startResult, 2030).map((item) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))
                  }
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='SR2'>1차 성과평가결과</label>
                <select id="SR2" onChange={(e) => { setStartResult2(e.target.value) }} value={startResult2}>
                  <option value="all">전체</option>
                  {startResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='REY'>2차 성과평가연도</label>
                <input
                  id='REY'
                  name="regEndYear"
                  placeholder=""
                  onChange={onChange}
                  value={regEndYear}
                />
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='ER2'>2차 성과평가결과</label>
                <select id="ER2" onChange={(e) => { setEndResult2(e.target.value) }} value={endResult2}>
                  <option value="all">전체</option>
                  {endResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>

              <div className='formWrap borderTop'>
                <label className='label' htmlFor='CO'>사후관리상태</label>
                <select id="CO" onChange={(e) => { setColor(e.target.value) }} value={regColor}>
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
                <col width="70px" />
                <col width="50px" />
                <col width="220px" />
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
                <col width="132px" />
                <col width="48px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width="54px" />
                <col width={isMobile ? "54px" : "34px"} />
                <col width={isMobile ? "54px" : "34px"} />
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
                  <th style={style.table.th} className='printHide'>수정</th>
                  <th style={style.table.th} className='printHide'>출력</th>
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
