document.addEventListener('DOMContentLoaded', function () {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  const input = document.getElementById('searchable_input');
  const precisionSelector = document.getElementById('precision_select');
  const searchTypeSelector = document.getElementById('search_type_select');

  const targetDiv = document.getElementById('result_container');

  let requestBody = { precision_selector_value: precisionSelector.value };

  // START: SELECTORS MANAGEMENT
  precisionSelector.disabled = searchTypeSelector.value === '0';

  searchTypeSelector.addEventListener('change', function () {
    precisionSelector.disabled = searchTypeSelector.value === '0';
    requestBody['precision_selector_value'] = precisionSelector.value;
  });
  // :END

  // START: ADDING LISTENERS
  input.addEventListener('input', handleInputChange);
  searchTypeSelector.addEventListener('change', handleInputChange);
  precisionSelector.addEventListener('change', handleInputChange);
  // :END

  function pushIntoTargetDiv(objects) {
    // function responsible for adding results to div

    for (let i = objects.length - 1; i >= 0; i--) {
      let div = document.createElement('div');
      div.classList.add('object-div');

      div.innerHTML = `
          <h2>${objects[i]['Name']}</h2>
          <p>Type: ${objects[i]['Type']}</p>
          <p>Value: ${objects[i]['Designed by']}</p>
        `;
      targetDiv.appendChild(div);
    }
  }

  function clearTargetDiv() {
    targetDiv.innerHTML = '';
  }

  function handleInputChange() {
    // function responsible for onchange action update data and fetch result

    requestBody['search_input_value'] = input.value;
    requestBody['search_type_selector_value'] = searchTypeSelector.value;

    if (searchTypeSelector.value === '1') {
      requestBody['precision_selector_value'] = precisionSelector.value;
    } else {
      delete requestBody['precision_selector_value'];
    }

    fetchResults();
  }

  function fetchResults(){
    // function responsible for fetching data from the server

    fetch('/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify(requestBody)
    })
        .then(response => response.json())
        .then(data => {
          clearTargetDiv();
          pushIntoTargetDiv(data);
        })
        .catch(error => {
          alert(error.message);
          console.error('Error:', error);
        });
  }
}, false);
