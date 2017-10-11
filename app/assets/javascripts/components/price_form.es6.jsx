var Modal = ReactBootstrap.Modal;
var Button = ReactBootstrap.Button;

class PriceForm extends React.Component {
  constructor(props) {
    super(props);
    this.Days = {
      sunday: 0,
      monday: 1,
      tuesday: 2,
      wednesday: 3,
      thursday: 4,
      friday: 5,
      saturday: 6
    };

    this.state = {
      price: props.price,
      showModal: props.showModal
    };
    this.state.price.courts = this.state.price.courts.map((c) => c.id)
  }

  componentWillReceiveProps(nextProps) {
    this.state = {
      price: nextProps.price,
      showModal: nextProps.showModal
    };
  }

  initSelectAll(checkbox) {
    if (!checkbox) return;
    var self = this;
    $(checkbox).change(function() {
      if (checkbox.checked)
        self.refs.courtsSelect.selectAll();
      else
        self.refs.courtsSelect.clear();
    });
  }

  initAllDays(checkbox) {
    if (!checkbox) return;
    $(checkbox).change(function() {
      $('.weekdays').prop('checked', checkbox.checked);
      $('.weekend').prop('checked', checkbox.checked);
    });
  }

  initWeekdays(checkbox) {
    if (!checkbox) return;
    $(checkbox).change(function() {
      $('.weekdays').prop('checked', checkbox.checked);
    });
  }

  initWeekend(checkbox) {
    if (!checkbox) return;
    $(checkbox).change(function() {
      $('.weekend').prop('checked', checkbox.checked);
    });
  }

  initDays(checkbox) {
    if (!checkbox) return;
    if (this.state.price.days.indexOf(this.Days[checkbox.dataset.day]) >= 0)
      checkbox.checked = true;
  }

  handleSubmit() {
    this.refs.remoteForm.submit.bind(this.refs.remoteForm)();
  }

  handleUpdate(resp, data) {
    var $row = $(resp);
    $('tr[data-price="' + $row.data('price') + '"').replaceWith($row);
    initPriceDel();
    this.props.closeHandler();
  }

  handleUpdateFail(resp, data) {
    this.props.closeHandler();
    toastr.error('something went wrong!');
    $('#modalPriceConflict').html($(resp.responseText)).modal('show');
  }

  render() {
    return(
      <Modal show={this.state.showModal} onHide={this.props.closeHandler}>
        {this.header()}
        {this.content()}
        {this.footer()}
      </Modal>
    );
  }

  header() {
    return(
      <Modal.Header>
        <Modal.Title>{I18n.t('venues.manage_price.header')} {this.state.price.id}</Modal.Title>
      </Modal.Header>
    );
  }

  content() {
    return(
      <Modal.Body>
        <RemoteForm actionUrl={this.state.price.update_url}
                    onSuccess={this.handleUpdate.bind(this)}
                    onError={this.handleUpdateFail.bind(this)}
                    ref="remoteForm">
            <div className="row">
              <div className="col-md-12">
                <ClockPicker label={I18n.t('venues.price_new.start_time_label')}
                             name={"price[start_time]"}
                             initialValue={this.state.price.start_time}/>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <ClockPicker label={I18n.t('venues.price_new.end_time_label')}
                             name={"price[end_time]"}
                             initialValue={this.state.price.end_time}/>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <Select2 label={ I18n.t('venues.price_new.select_court_label')}
                        ref="courtsSelect"
                        data={this.props.courts}
                        placeholder="Select Courts"
                        multiple={true}
                        name="court_ids[]"
                        initialValue={this.state.price.courts}/>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <div className="form-group">
                  <input type="checkbox" id="checkbox" ref={this.initSelectAll.bind(this)} />{I18n.t('venues.price_new.select_all_courts')}
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <div className="form-group has-feedback">
                  <label className="control-label">{I18n.t('venues.price_new.price')}</label>
                  <input type="text" className="form-control"
                         placeholder={I18n.t('venues.price_new.price')}
                         name="price[price]"
                         defaultValue={this.state.price.value}
                         required/>
                  <i className="fa fa-eur form-control-feedback"></i>
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <div className="form-group">
                  <label >{ I18n.t('venues.price_new.choose_dates')}</label>
                  <span className="fa fa-eur"></span>
                </div>
              </div>
            </div>
            <div id="list">
              <div className="col-md-6">
                <div className="form-group">
                  <label for="monday">{I18n.t('date.day_names')[1]}</label>
                  <input type="checkbox" name="price[monday]" data-day='monday' ref={this.initDays.bind(this)} className="weekdays" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="tuesday">{ I18n.t('date.day_names')[2]} </label>
                  <input type="checkbox" name="price[tuesday]" data-day='tuesday' ref={this.initDays.bind(this)} className="weekdays" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="wednesday">{I18n.t('date.day_names')[3]} </label>
                  <input type="checkbox" name="price[wednesday]" data-day='wednesday' ref={this.initDays.bind(this)} className="weekdays" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="thursday">{I18n.t('date.day_names')[4]}</label>
                  <input type="checkbox" name="price[thursday]" data-day='thursday' ref={this.initDays.bind(this)} className="weekdays" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="friday">{I18n.t('date.day_names')[5]}</label>
                  <input type="checkbox" name="price[friday]" data-day='friday' ref={this.initDays.bind(this)} className="weekdays" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="saturday"> { I18n.t('date.day_names')[6] } </label>
                  <input type="checkbox" name="price[saturday]" data-day='saturday' ref={this.initDays.bind(this)} className="weekend" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="sunday"> { I18n.t('date.day_names')[0] } </label>
                  <input type="checkbox" name="price[sunday]" data-day='sunday' ref={this.initDays.bind(this)} className="weekend" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="sunday"> { I18n.t('venues.price_new.weekdays') } </label>
                  <input type="checkbox" ref={this.initWeekdays} value="1" name="weekdays" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="sunday"> { I18n.t('venues.price_new.weekend') } </label>
                  <input type="checkbox" ref={this.initWeekend} value="1" name="weekend" />
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group">
                  <label for="sunday"> { I18n.t('venues.price_new.all_days') } </label>
                  <input type="checkbox" ref={this.initAllDays} value="1" name="all" />
                </div>
              </div>
            </div>
        </RemoteForm>
      </Modal.Body>
    );
  }

  footer() {
    return(
       <Modal.Footer>
         <Button className="btn btn-default" onClick={this.handleSubmit.bind(this)}>
           {I18n.t('venues.manage_price.update_button')}
         </Button>
         <Button className="btn btn-default" onClick={this.props.closeHandler}>
           {I18n.t('venues.manage_price.cancel_button')}
         </Button>
       </Modal.Footer>
    );
  }
}
