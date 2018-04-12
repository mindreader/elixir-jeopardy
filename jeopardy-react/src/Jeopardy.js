import React from 'react';
import './Jeopardy.css';

function Answer(props) {
  return <div className="answer">{props.answer}</div>
}

function Question(props) {
  return <div className="question">{props.question}</div>
}

function Category(props) {
  if (props.clickCat) {
    return <div className="category" onClick={ () => props.clickCat(props.category) }>{props.category}</div>
  }
  else {
    return <div className="category" >{props.category}</div>
  }
}

function Categories(props) {
  const cats = props.categories.map((cat, i) =>
    <li key={cat}><Category key={cat} category={cat} clickCat={props.clickCat} /></li>
  )
  return (
      <div>
        <ul className="unbulletted">
          {cats}
        </ul>
      </div>)
}

class Jeopardy extends React.Component {

  constructor(props) {
    super(props)
    this.categoryClicked = this.categoryClicked.bind(this);
    this.questionClicked = this.questionClicked.bind(this);

    this.state = {
      isLoaded: false,
      error: null,
      categories: [],
      question_category: null, 
      questions: [],
    }
  }

  componentDidMount() {
    this.loadCategories()
  }

  loadCategories() {
    fetch("api/categories/random")
      .then(response => response.json())
      .then(json => 
        this.setState({
          isLoaded: true,
          categories: json.categories
        })
        , error =>
        this.setState({
          error: error.message
        })
      )
  }

  questionClicked() {
    if (this.state.answerShown) {
      this.setState({
        questions: this.state.questions.slice(1),
        answerShown: false,
      })
    }
    else {
      this.setState({
        answerShown: true,
      })
    }

  }

  async categoryClicked(cat) {
    this.loadQuestions(cat)
  }

  loadQuestions(cat) {

    fetch("api/questions/bycategory/" + encodeURIComponent(cat))
      .then(response => response.json())
      .then(json => {
        this.setState({
          isLoaded: true,
          questions: json.questions,
          question_category: json.category,
          answerShown: false,
        })

        this.loadCategories()
      }
         // preemptively load categories
       , error =>
        this.setState({
          error: error
        })
      )
  }

  container(contents) {
    return (
      <div className="jeopardy">
        <div className="font_preload">
          <span className="helveticacompressed"></span>
          <span className="scakorinnabold"></span>
        </div>
      {contents}
      </div>)
  }

  render() {

    // I wish javascript had adts...

    if (this.state.error) {
      return this.container(<div>ERROR: {this.state.error}</div>)
    }
    else if (!this.state.isLoaded) {
      return this.container(<div>One moment...</div>)
    }
    else if (this.state.questions.length <= 0) {
      return this.container(
        <div className="categories">
          <Categories categories={this.state.categories} clickCat={this.categoryClicked}/>
        </div>
      );
    } else {

      const answer = this.state.answerShown ? <Answer answer={this.state.questions[0].answer}/> : null;
      return this.container(
        <div onClick={this.questionClicked} className="quiz">
          <Category category={this.state.question_category}/>
          <Question question={this.state.questions[0].question}/>
          {answer}
        </div>
      )
    }
  }
}

export default Jeopardy;
