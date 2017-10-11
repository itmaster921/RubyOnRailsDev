var Table = ReactBootstrap.Table;

class GamePassList extends React.Component {
  constructor(props) {
    super(props);
  }

  renderGamePasses() {
    var self = this;
    var game_passes = this.props.game_passes.map(function(game_pass, index) {
      return(<GamePassListItem game_pass={game_pass}
        key={index}
        gamePassIndex={index}
        edit_game_pass={self.props.edit_game_pass}
        delete_game_pass={self.props.delete_game_pass}
             />);
    });
    return(
      <div>
        <Table responsive>
          <thead>
            <tr>
              <th>{I18n.t('game_pass.user')}</th>
              <th>{I18n.t('game_pass.total_charges')}</th>
              <th>{I18n.t('game_pass.remaining_charges')}</th>
              <th>{I18n.t('game_pass.price')}</th>
              <th>{I18n.t('game_pass.show_limitations')}</th>
              <th>{I18n.t('game_pass.actions')}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {game_passes}
          </tbody>
        </Table>
      </div>
    );
  }

  renderEmpty() {
      return(
        <div>-</div>
      );
  }

  render() {
    var content;
    if (this.props.game_passes.length)
      content = this.renderGamePasses();
    else
      content = this.renderEmpty();
    return content;
  }
}
